package nengine.systems;
import ecs.Entity;
import ecs.System;
import ecs.World;
import nengine.components.AIContainer;
using Lambda;

class AISystem implements System
{
    public var world:World;
    public function new() { }

    public function update(dt:Float)
    {
        var entities = world.getEntities([AIContainer.componentName]);
        entities.iter(aiUpdate);
    }

    private function aiUpdate(entity:Entity):Void
    {
        var container = entity.getComponent(AIContainer);
        var controller = container.controllers.find((controller)->controller.isActive());
        controller.update();
        container.entityOperator.update(controller);
    }
}
