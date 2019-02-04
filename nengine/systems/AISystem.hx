package nengine.systems;
import ecs.System;
import ecs.World;
import nengine.components.AIContainer;
using Lambda;

class AISystem implements System
{
    public var world:World;
    public function new(world:World)
    {
        world.addSystem(this);
    }

    public function update(dt:Float)
    {
        var entities = world.getEntities(["AIContainer"]);
        entities.iter((entity)->{
            cast (entity.getComponent("AIContainer"), AIContainer)
                .aiNodes
                .find((aiNode)->aiNode.isActive(entity))
                .task(entity);
        });
    }
}
