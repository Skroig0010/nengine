package nengine.physics.collision.shapes;
import nengine.math.*;
import nengine.physics.collision.ShapeCell;
import nengine.components.RigidBody;

class CircleShape implements Shape
{
    public var type(default, never) = ShapeType.Circle;
    public var radius:Float;
    public var position:Vec2;
    public var isSensor:Bool;
    public var body:RigidBody;
    public var cell(default, null):ShapeCell;
    public var id(default, null):Int;
    public var friction:Float = 0.2;
    public var restitution:Float = 0.0;

    public function new(position:Vec2, radius:Float)
    {
        this.position = position;
        this.radius = radius;
        this.isSensor = false;
        cell = new ShapeCell(this);
        id = ShapeIdCounter.getId();
    }

    public function computeAABB(transform:Transform2):AABB2
    {
        var center = transform * position;
        var upperBound = new Vec2(center.x - radius, center.y - radius);
        var lowerBound = new Vec2(center.x + radius, center.y + radius);
        return new AABB2(upperBound, lowerBound);
    }

    public function computeMass(density:Float):MassData
    {
        var massData = new MassData();
        massData.mass = density * Settings.pi * radius * radius;
        massData.center = position;

        // inertia about the local origin
        massData.inertia = massData.mass * (0.5 * radius * radius + position.dot(position));
        return massData;
    }
}
