package nengine.components.shapes;
import nengine.math.*;

class CircleShape implements Shape
{
    public var type(default, never) = ShapeType.Circle;
    public var radius:Float;
    public var position:Vec2;

    public function new(position:Vec2, radius:Float)
    {
        this.position = position;
        this.radius = radius;
    }

    public function computeAABB(transform:Transform2):AABB2
    {
        var center = transform * position;
        var upperBound = new Vec2(center.x - radius, center.y - radius);
        var lowerBound = new Vec2(center.x + radius, center.y + radius);
        return new AABB2(upperBound, lowerBound);
    }

    public function clone():CircleShape
    {
        return new CircleShape(position.copy(), radius);
    }
}
