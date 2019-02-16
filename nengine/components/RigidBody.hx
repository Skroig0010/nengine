package nengine.components;
import ecs.Entity;
import ecs.Component;
import ecs.Signal;
import nengine.box2d.dynamics.B2Body;
import nengine.box2d.dynamics.B2BodyDef;
import nengine.box2d.dynamics.B2FixtureDef;
import nengine.box2d.dynamics.B2World;
import nengine.math.*;
import nengine.systems.PhysicsSystem;

// Box2Dのbody
class RigidBody implements Component
{
    // Component Data
    public var name(default, never) = "RigidBody";
    private var b2World:B2World;
    private var body:B2Body;

    public function new(system:PhysicsSystem, bodyDef:B2BodyDef, fixtureDef:B2FixtureDef)
    {
        b2World = system.b2World;
        body = b2World.CreateBody(bodyDef);
        body.CreateFixture(fixtureDef);
    }
}
