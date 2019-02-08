package nengine.components;
import ecs.Component;
import ecs.Entity;
import nengine.math.*;

interface Shape
{
    public function onBroadPhase(other:Collider):Bool;
    public function on(other:Collider):Bool;
    public function resolveCollision(other:Collider):Void;
}
