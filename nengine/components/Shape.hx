package nengine.components;
import ecs.Component;
import ecs.Entity;
import nengine.math.*;

interface Shape
{
    public function onBroadPhase(other:Shape):Bool;
    public function on(other:Shape):Bool;
}
