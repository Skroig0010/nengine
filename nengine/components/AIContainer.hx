package nengine.components;

import ecs.Component;
import nengine.components.ai.*;

class AIContainer implements Component
{
    public inline static var componentName = "AIContainer";
    public var name(default, never) = componentName;

    public var controllers(default, null):List<Controller>;
    public var entityOperator(default, null):EntityOperator;

    public function new(entityOperator:EntityOperator, controllers:Array<Controller>)
    {
        this.entityOperator = entityOperator;
        this.controllers = Lambda.list(controllers);
    }
}
