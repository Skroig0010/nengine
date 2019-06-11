package nengine.components;

import ecs.Component;
import nengine.components.ai.*;

class AIContainer<Button, Stick> implements Component
{
    public inline static var componentName = "AIContainer";
    public var name(default, never) = componentName;

    public var controllers(default, null):List<Controller<Button, Stick>>;
    public var entityOperator(default, null):EntityOperator<Button, Stick>;

    public function new(entityOperator:EntityOperator<Button, Stick>, controllers:Array<Controller<Button, Stick>>)
    {
        this.entityOperator = entityOperator;
        this.controllers = Lambda.list(controllers);
    }
}
