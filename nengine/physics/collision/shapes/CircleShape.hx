package nengine.physics.collision.shapes;
import nengine.components.Collider;
import nengine.math.*;

class CircleShape implements Shape
{
    public var type(default, never) = ShapeType.Circle;
    public var radius:Float;
    public var position:Vec2;
    public var isSensor:Bool;
    public var cell(default, null):ShapeCell;
    public var id(default, null):Int;

    public function new(position:Vec2, radius:Float, collider:Collider)
    {
        this.position = position;
        this.radius = radius;
        this.isSensor = false;
        cell = new ShapeCell(this, collider);
        id = ShapeIdCounter.getId();
    }

    public function computeAABB(transform:Transform2):AABB2
    {
        var center = transform * position;
        var upperBound = new Vec2(center.x - radius, center.y - radius);
        var lowerBound = new Vec2(center.x + radius, center.y + radius);
        return new AABB2(upperBound, lowerBound);
    }

    public function clone(collider:Collider):CircleShape
    {
        return new CircleShape(position.copy(), radius, collider);
    }
}
