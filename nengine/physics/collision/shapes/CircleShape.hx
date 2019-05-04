package nengine.physics.collision.shapes;
import nengine.math.*;
import nengine.physics.collision.ShapeCell;
import nengine.components.RigidBody;

class CircleShape implements Shape
{
    public var body:RigidBody;
    public var cell(default, null):ShapeCell;
    public var radius:Float;
    public var position:Vec2;

    public function new(position:Vec2, radius:Float)
    {
        this.position = position;
        this.radius = radius;
        cell = new ShapeCell(this);
    }

    public function computeAABB(transform:Transform2):AABB2
    {
        var center = transform * position;
        var upperBound = new Vec2(center.x - radius, center.y - radius);
        var lowerBound = new Vec2(center.x + radius, center.y + radius);
        return new AABB2(upperBound, lowerBound);
    }

}
