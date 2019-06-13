package nengine.physics.collision.shapes;
import nengine.math.*;
import nengine.physics.collision.ShapeCell;
import nengine.components.RigidBody;

class CircleShape implements Shape
{
    public var type(default, never) = ShapeType.Circle;
    public var body:RigidBody;
    public var isSensor:Bool;
    public var cell(default, null):ShapeCell;
    public var friction:Float;
    public var restitution:Float;
    public var density:Float;
    public var radius:Float;
    // 比較用
    public var id(default, null):Int;

    public var position:Vec2;

    public function new(position:Vec2, radius:Float, density:Float = 0.0, friction:Float = 0.2, restitution:Float = 0.0, isSensor:Bool = false)
    {
        this.position = position;
        this.radius = radius;
        this.isSensor = isSensor;
        this.density = density;
        this.friction = friction;
        this.restitution = restitution;
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

    public function computeMass():MassData
    {
        var massData = new MassData();
        massData.mass = density * Math.PI * radius * radius;
        massData.center = position;

        // inertia about the local origin
        massData.inertia = massData.mass * (0.5 * radius * radius + position.dot(position));
        return massData;
    }
}
