package nengine.systems;
import ecs.Component;
import ecs.Entity;
import ecs.System;
import ecs.World;
import nengine.box2d.dynamics.B2World;
import nengine.box2d.common.math.B2Vec2;
import nengine.components.RigidBody;
using Lambda;

// box2dのworld
class PhysicsSystem implements System
{
    public var world:World;
    public var b2World(default, null):B2World;
    public function new(world:World)
    {
        world.addSystem(this);
        b2World = new B2World(new B2Vec2(0,10), true);
    }

    public function update(dt:Float):Void
    {
        b2World.Step(dt, 10, 10);
        b2World.ClearForces();

        var entities = world.getEntities(["RigidBody", "Transform"]);
        for(entity in entities)
        {
            var transform = entity.getComponent("Transform");
            var body = entity.getComponent("RigidBody");
        }
    }
}
