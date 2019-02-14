package nengine.systems;
import ecs.Component;
import ecs.Entity;
import ecs.System;
import ecs.World;
import nengine.components.RigidBody;
using Lambda;

// box2dのworld
class PhysicsSystem implements System
{
    public var world:World;
    public function new(world:World)
    {
        world.addSystem(this);
    }

    public function update(dt:Float)
    {
    }
}
