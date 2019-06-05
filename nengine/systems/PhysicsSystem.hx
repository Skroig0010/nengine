package nengine.systems;
import ecs.Entity;
import ecs.System;
import ecs.World;
import nengine.components.RigidBody;
import nengine.components.Transform;
import nengine.math.*;
import nengine.physics.collision.shapes.Shape;
import nengine.physics.collision.BroadPhase;
import nengine.physics.collision.QuadTree;
import nengine.physics.dynamics.contacts.Contact;
import nengine.physics.dynamics.contacts.ContactSolver;
import nengine.physics.dynamics.ContactManager;
import nengine.physics.dynamics.TimeStep;
import nengine.physics.dynamics.Position;
import nengine.physics.dynamics.Velocity;

class PhysicsSystem implements System
{
    public var world:World;
    public var velocityIterations = 10;
    public var positionIterations = 10;
    public var flags:Int = 0;
    public var gravity = new Vec2();

    private var contactManager:ContactManager;
    private var bodies = new Array<RigidBody>();
    private var positions = new Array<Position>();
    private var velocities= new Array<Velocity>();


    private var prevInvDt:Float = 0;
    private var warmStarting:Bool = true;

    private var addedBodies = new List<RigidBody>();
    private var addedShapes = new List<{shape:Shape, transform:Transform2}>();
    private var removedBodies = new List<RigidBody>();
    private var removedShapes = new List<Shape>();
    
    public static inline var newShapeFlag = 0x0001;
    public static inline var lockedFlag = 0x0002;
    public static inline var clearForcesFlag = 0x0004;

    public function new(world:World, area:AABB2, unit:AABB2)
    {
        world.addSystem(this);

        // quadtreeレベル推定
        var areaSize = area.lowerBound - area.upperBound;
        var unitSize = unit.lowerBound - unit.upperBound;
        var divX = areaSize.x / (unitSize.x * 2);
        var divY = areaSize.y / (unitSize.y * 2);
        var div = Std.int(Math.min(divX, divY));

        // calculate tree level
        var level = 0;
        while(div != 0)
        {
            level++;
            div >>= 1;
        }
        level--;

        contactManager = new ContactManager(new BroadPhase(new QuadTree(level, area)));

        world.getEntities([RigidBody.componentName]).map(onEntityAdded);
        world.entityAdded([RigidBody.componentName]).add(onEntityAdded);
        world.entityRemoved([RigidBody.componentName]).add(onEntityRemoved);
    }

    private function onEntityAdded(entity:Entity):Void
    {
        addBody(entity.getComponent(RigidBody));
    }

    private function onEntityRemoved(entity:Entity):Void
    {
        destroyBody(entity.getComponent(RigidBody));
    }

    private function addBody(body:RigidBody):Void
    {
        // ロックされていたら別の場所に避難
        if(flags & lockedFlag != 0)
        {
            addedBodies.add(body);
        }
        else
        {
            // contactManager.broadPhase.addBody(body);
            bodies.push(body);
        }
    }

    private function destroyBody(body:RigidBody):Void
    {
        // ロックされていたら別の場所に避難
        if(flags & lockedFlag != 0)
        {
            removedBodies.add(body);
        }
        else
        {
            // contactManager.broadPhase.removeBody(body);
            bodies.remove(body);
        }
    }

    public function touchShape(shape:Shape):Void
    {
        contactManager.broadPhase.touchShape(shape);
    }

    public function destroyContact(contact:Contact):Void
    {
        contactManager.destroy(contact);
    }

    // RigidBodyのaddShapeが呼んでくれるからこっちは呼ぶな
    public function addShape(shape:Shape, transform:Transform2):Void
    {
        // ロックされていたら別の場所に避難
        if(flags & lockedFlag != 0)
        {
            addedShapes.add({
                shape:shape,
                transform:transform
            });
        }
        else
        {
            contactManager.broadPhase.addShape(shape, transform);
            flags |= newShapeFlag;
        }
    }

    // RigidBodyのremoveShapeが呼んでくれるからこっちは呼ぶな
    public function removeShape(shape:Shape):Void
    {
        // ロックされていたら別の場所に避難
        if(flags & lockedFlag != 0)
        {
            removedShapes.add(shape);
        }
        else
        {
            contactManager.broadPhase.removeShape(shape);
        }
    }

    public function synchronizeShapes(body:RigidBody):Void
    {
        var transform = body.transform;
        for(shape in body)
        {
            contactManager.broadPhase.moveShape(shape, transform);
        }
    }


    public function update(dt:Float):Void
    {
        if(flags & newShapeFlag != 0)
        {
            contactManager.findNewContacts();
            flags &= ~newShapeFlag;
        }

        flags |= lockedFlag;

        var step = new TimeStep();
        step.dt = dt;
        step.velocityIterations = velocityIterations;
        step.positionIterations = positionIterations;
        if(dt > 0.0)
        {
            step.invDt = 1.0 / dt;
        }
        else
        {
            step.invDt = 0.0;
        }

        step.dtRatio = prevInvDt * dt;
        step.warmStarting = warmStarting;

        contactManager.collide();

        if(dt > 0.0)
        {
            solve(step);
            prevInvDt = step.invDt;
        }

        if(flags & clearForcesFlag != 0)
        {
            clearForces();
        }

        for(body in bodies)
        {
            var entity = body.entity;
            if(entity.hasComponent(Transform.componentName))entity.getComponent(Transform).global = body.transform;
        }

        flags &= ~lockedFlag;

        // 追加や削除できなかったBodyやShapeを追加
        addedBodies.iter(addBody);
        removedBodies.iter(destroyBody);
        addedShapes.iter((val)->addShape(val.shape, val.transform));
        removedShapes.iter(removeShape);
    }

    private function clearForces()
    {
        for(body in bodies)
        {
            body.force.setZero();
            body.torque = 0.0;
        }
    }

    private function solve(step:TimeStep):Void
    {
        var dt = step.dt;

        for(index in 0...bodies.length)
        {
            var body = bodies[index];
            body.index = index;
            var position = body.transform * body.localCenter;
            var rotation = body.transform.rotation;
            var linearVelocity = body.linearVelocity;
            var angularVelocity = body.angularVelocity;
            if(body.type == DynamicBody)
            {
                linearVelocity += dt * (body.gravityScale * gravity + body.invMass * body.force);
                angularVelocity += dt * body.invInertia * body.torque;
                // 空気抵抗による減衰の適用
                linearVelocity *= 1.0 / (1.0 + dt * body.linearDamping);
                angularVelocity *= 1.0 / (1.0 + dt * body.angularDamping);
            }
            if(positions.length <= index) positions.push(new Position());
            positions[index].c = position;
            positions[index].a = rotation.getAngle();
            if(velocities.length <= index) velocities.push(new Velocity());
            velocities[index].v = linearVelocity;
            velocities[index].w = angularVelocity;
        }
        if(positions.length > bodies.length)positions = positions.splice(0, bodies.length);
        if(velocities.length > bodies.length)velocities = velocities.splice(0, bodies.length);

        var contactSolver = new ContactSolver(step, contactManager.contacts, positions, velocities);
        contactSolver.initializeVelocityConstraints();

        if(step.warmStarting)
        {
            contactSolver.warmStart();
        }

        for(_ in 0...step.velocityIterations)
        {
            contactSolver.solveVelocityConstraints();
        }

        contactSolver.storeImpulses();

        // integrate positions
        for(index in 0...bodies.length)
        {
            var c = positions[index].c;
            var a = positions[index].a;
            var v = velocities[index].v;
            var w = velocities[index].w;

            // check for large velocities
            var translation = dt * v;
            if(translation.dot(translation) > Settings.maxTranslationSquared)
            {
                var ratio = Settings.maxTranslation / translation.length();
                v *= ratio;
            }

            var rotation = dt * w;
            if(rotation * rotation > Settings.maxRotationSquared)
            {
                var ratio = Settings.maxRotation / Math.abs(rotation);
                w *= ratio;
            }

            // integrate
            c += dt * v;
            a += dt * w;

            positions[index].c = c;
            positions[index].a = a;
            velocities[index].v = v;
            velocities[index].w = w;
        }

        var positionSolved = false;
        for(_ in 0...step.positionIterations)
        {
            if(contactSolver.solvePositionConstraints())
            {
                positionSolved = true;
                break;
            }
        }

        // バッファ内容をbodyに
        for(index in 0...bodies.length)
        {
            var body = bodies[index];
            body.transform.rotation.set(positions[index].a);
            body.transform.position = positions[index].c - body.transform.rotation * body.localCenter;

            body.linearVelocity = velocities[index].v;
            body.angularVelocity = velocities[index].w;
        }

        // Synchronize fixtures, check for out of range bodies.
        for(body in bodies)
        {
            if(body.type == StaticBody)continue;
            synchronizeShapes(body);
        }

        contactManager.findNewContacts();
    }
}
