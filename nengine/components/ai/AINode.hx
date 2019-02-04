package nengine.components.ai;
import ecs.Entity;

interface AINode
{
    public function isActive(entity:Entity):Bool;
    public function task(entity:Entity):Void;
}
