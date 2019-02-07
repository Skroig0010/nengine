package nengine.components;
import ecs.Component;
import ecs.Entity;
import nengine.math.*;

interface Shape2D extends Shape extends Transformable<Transform2DBase>
{
    // Broad Phase用
    public var size(default, null):Vec2;
}
