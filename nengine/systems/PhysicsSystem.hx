package nengine.systems;
import ecs.System;
import ecs.World;

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
