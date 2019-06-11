package nengine.components;
import ecs.Entity;
import ecs.Component;
import ecs.Signal;
import nengine.components.Transform;
import nengine.math.*;
import nengine.systems.PhysicsSystem;
import nengine.physics.collision.shapes.*;
import nengine.physics.collision.ShapeCell;
import nengine.physics.dynamics.contacts.ContactEdge;

// Box2Dのbody
class RigidBody implements Component
{
    // Component Data
    public inline static var componentName = "RigidBody";
    public var name(default, never) = componentName;
    public var entity:Entity;
    private var shapes = new Array<Shape>();

    public var contactEdges:ContactEdge;

    public var mass(default, null):Float = 1;
    public var invMass(default, null):Float = 1;
    public var inertia(default, null):Float = 1;
    public var invInertia(default, null):Float = 1;

    public var transform:Transform2;
    public var force = new Vec2();
    public var torque:Float = 0.0;
    public var linearVelocity = new Vec2();
    public var angularVelocity:Float = 0.0;
    public var linearDamping:Float = 0.0;
    public var angularDamping:Float = 0.0;
    public var gravityScale:Float = 0.0;
    public var localCenter = new Vec2();

    @:isVar public var type(default, set):BodyType = DynamicBody;
    private function set_type(type:BodyType):BodyType
    {
        Settings.assert(system.flags & PhysicsSystem.lockedFlag == 0);
        if(system.flags & PhysicsSystem.lockedFlag != 0) return this.type;
        if(this.type == type) return type;

        this.type = type;
        resetMassData();
        switch(this.type)
        {
            case StaticBody:
            linearVelocity.setZero;
            angularVelocity = 0.0;
            system.synchronizeShapes(this);
            case DynamicBody | KinematicBody:
        }
        force.setZero();
        torque = 0.0;

        // delete attached contacts
        var ce = contactEdges;
        while(ce != null)
        {
            var ce0 = ce;
            ce = ce.next;
            system.destroyContact(ce0.contact);
        }
        contactEdges = null;

        for(shape in shapes)
        {
            system.touchShape(shape);
        }

        return this.type;

    }
    public var flags:Int = 0;

    public var system:PhysicsSystem;

    // islandIndex的な
    public var index:Int = 0;

    // flags
    public static inline var fixedRotationFlag = 0x0010;

    private inline function invOr0(value:Float):Float
    {
        return if(value != 0)
        {
            1 / value;
        }
        else
        {
            0;
        }
    }

    public function new(entity:Entity, shapes:Array<Shape>, system:PhysicsSystem)
    {
        this.entity = entity;
        this.system = system;
        this.transform = if(entity.hasComponent(Transform.componentName)) entity.getComponent(Transform).global else new Transform2();
        for(shape in shapes)
        {
            addShape(shape);
        }
    }

    public function addShape(shape:Shape):Void
    {
        shapes.push(shape);
        shape.body = this;
        system.addShape(shape, transform);
        if(shape.density > 0.0)resetMassData();
    }

    public function removeShape(shape:Shape):Void
    {
        shapes.remove(shape);
        if(shape.body == this)shape.body = null;
        system.removeShape(shape);
        resetMassData();
    }

    public inline function iterator():Iterator<Shape>
    {
        return shapes.iterator();
    }

    public function resetMassData():Void
    {
        mass = 0.0;
        invMass = 0.0;
        inertia = 0.0;
        invInertia = 0.0;
        localCenter.setZero();
        switch(type)
        {
            case StaticBody | KinematicBody:
                return;
            case DynamicBody:
                // accumulate mass over all shapes
                var localCenter = new Vec2();
                for(shape in shapes)
                {
                    if(shape.density == 0.0) continue;

                    var massData = shape.computeMass();
                    mass += massData.mass;
                    localCenter += massData.mass * massData.center;
                    inertia += massData.inertia;
                }
                // compute center of mass
                if(mass > 0.0) 
                {
                    invMass = invOr0(mass);
                    localCenter *= invMass;
                }
                else
                {
                    mass = 1.0;
                    invMass = 1.0;
                }

                if(inertia > 0.0 && (flags & fixedRotationFlag) == 0)
                {
                    // center the inertia about the center of mass
                    inertia -= mass * localCenter.dot(localCenter);
                    Settings.assert(inertia > 0.0);
                    invInertia = invOr0(inertia);
                }
                else
                {
                    inertia = 0;
                    invInertia = 0;
                }

                // move center of mass
                var oldCenter = transform * this.localCenter;
                this.localCenter = localCenter;
                linearVelocity += Vec2.crossFV(angularVelocity, transform * localCenter - oldCenter);

        }
    }

    public inline function applyForce(force:Vec2, point:Vec2):Void
    {
        switch(type)
        {
            case DynamicBody:
                this.force += force;
                this.torque += (point - transform * localCenter).cross(force);
            case StaticBody | KinematicBody:
        }
    }

    public inline function applyForceToCenter(force:Vec2):Void
    {
        switch(type)
        {
            case DynamicBody:
                this.force += force;
            case StaticBody | KinematicBody:
        }
    }

    public inline function applyTorque(torque:Float):Void
    {
        switch(type)
        {
            case DynamicBody:
                this.torque += torque;
            case StaticBody | KinematicBody:
        }
    }

    public inline function applyLinearImpulse(impulse:Vec2, point:Vec2):Void
    {
        switch(type)
        {
            case DynamicBody:
                linearVelocity += invMass * impulse;
                angularVelocity += invInertia * (point - transform * localCenter).cross(impulse);
            case StaticBody | KinematicBody:
        }
    } 

    public inline function applyLinearImpulseToCenter(impulse:Vec2):Void
    {
        switch(type)
        {
            case DynamicBody:
                linearVelocity += invMass * impulse;
            case StaticBody | KinematicBody:
        }
    } 

    public inline function applyAngularImpulse(impulse:Float, point:Vec2):Void
    {
        switch(type)
        {
            case DynamicBody:
                angularVelocity += invInertia * impulse;
            case StaticBody | KinematicBody:
        }
    }
}
