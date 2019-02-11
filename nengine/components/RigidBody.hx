package nengine.components;
import ecs.Entity;
import ecs.Component;
import ecs.Signal;
import nengine.components.Transform;
import nengine.math.*;
import nengine.physics.collision.shapes.AABB2;
import nengine.physics.collision.shapes.Shape2;
import nengine.physics.dynamics.Fixture2;
import nengine.systems.PhysicsSystem;

// Box2Dのbody
class RigidBody implements Component
{
    public static var isLandFlag(default, never) = 0x0001;
    public static var awakeFlag(default, never) = 0x0002;
    public static var allowSleepFlag(default, never) = 0x0004;
    public static var bulletFlag(default, never) = 0x0008;
    public static var fixedRotationFlag(default, never) = 0x0010;
    public static var activeFlag(default, never) = 0x0020;
    public static var staticBody(default, never) = 0;
    public static var kinematicBody(default, never) = 1;
    public static var dynamicBody(default, never) = 2;

    public var name(default, never) = "RigidBody";
    public var fixtures(default, null) = new Array<Fixture2>();
    public var layer(default, set):String;
    public var onLayerChanged = new Signal<{entity:Entity, collider:RigidBody}>();
    private var entity:Entity;
    public var isStatic(default, null):Bool;
    public var onCollide:Entity->Void;
    public var physicsSystem:PhysicsSystem;
    public var flags:Int;

    public var mass:Float;
    public var invMass:Float;
    public var inertia:Float;
    public var invInertia:Float;
    public var inertiaScale:Float;
    public var sweep = new Sweep2();
    public var type:Int;
    public var linearVelocity = new Vec2();
    public var force = new Vec2();
    public var angularVelocity:Float;

    public function new(physicsSystem:PhysicsSystem, entity:Entity, layer:String, isTrigger:Bool, isStatic:Bool)
    {
        this.physicsSystem = physicsSystem;
        this.layer = layer;
        this.entity = entity;
        this.isStatic = isStatic;
    }

    public function createFixture(shape:Shape2, friction:Float, restitution:Float, density:Float, ?isSensor:Bool = false):Fixture2
    {
        var fixture = new Fixture2(shape, friction, restitution, density, entity, isSensor);
        if (flags & activeFlag != 0) {
            var broadPhase = physicsSystem.contactManager.broadPhase;
            fixture.createProxy(broadPhase, cast (entity.getComponent("Transform"), Transform).global);
        }
        if (fixture.density > 0.0) {
            resetMassData();
        }
        fixtures.push(fixture);
        physicsSystem.flags |= PhysicsSystem.newFixture;
        return fixture;
    }

    public function resetMassData():Void
    { 
        mass = 0.0;
        invMass = 0.0;
        inertia = 0.0;
        invInertia = 0.0;
        sweep.localCenter.setZero();

        if (type == staticBody || type == kinematicBody) {
            return;
        }

        var center = new Vec2();
        for (f in fixtures) {
            if (f.density == 0.0) {
                continue;
            }
            var massData = f.getMassData();
            mass += massData.mass;
            center.x += massData.centeroid.x * massData.mass;
            center.y += massData.centeroid.y * massData.mass;
            inertia += massData.inertia;
        }

        if (mass > 0.0) 
        {
            invMass = 1.0 / mass;
            center.x *= invMass;
            center.y *= invMass;
        }
        else 
        {
            mass = 1.0;
            invMass = 1.0;
        }
        if (inertia > 0.0 && (flags & fixedRotationFlag) == 0) {
            inertia -= mass * (center.x * center.x + center.y * center.y);
            inertia *= inertiaScale;
            nengine.physics.Settings.assert(inertia > 0);
            invInertia = 1.0 / inertia;
        }
        else {
            inertia = 0.0;
            invInertia = 0.0;
        }
        var oldCenter = sweep.c.copy();
        sweep.localCenter.setV(center);
        sweep.c0.setV((cast (entity.getComponent("Transform"), Transform).global) * sweep.localCenter);
        sweep.c.setV(sweep.c0);
        linearVelocity.x += angularVelocity * (-sweep.c.y + oldCenter.y);
        linearVelocity.y += angularVelocity * (sweep.c.x - oldCenter.x);
    }

    private function set_layer(layer:String):String
    {
        this.layer = layer;
        onLayerChanged.emit({entity:entity, collider:this});
        return layer;
    }
}
