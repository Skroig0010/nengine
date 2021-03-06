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
    public var name:String;
    // 比較用
    public var id(default, null):Int;

    public var position:Vec2;

    public function new(position:Vec2, radius:Float, density:Float = 0.0, friction:Float = 0.2, restitution:Float = 0.0, isSensor:Bool = false, name:String = "")
    {
        this.position = position;
        this.radius = radius;
        this.isSensor = isSensor;
        this.density = density;
        this.friction = friction;
        this.restitution = restitution;
        this.name = name;
        cell = new ShapeCell(this);
        id = ShapeIdCounter.getId();
    }

    public function testPoint(transform:Transform2, p:Vec2):Bool
    {
        var center = transform * position;
        var d = p - center;
        return d.dot(d) <= radius * radius;
    }

    public function rayCast(input:RayCastInput, transform:Transform2):Option<RayCastOutput>
    {
        var s = input.p1 - transform * position;
        var b = s.dot(s) - radius * radius;

        // Solve quadratic equation
        var r = input.p2 - input.p1;
        var c = s.dot(r);
        var rr = r.dot(r);
        var sigma = c * c - rr * b;

        // Check for negative discriminant and short segment
        if(sigma < 0.0 || rr < Settings.epsilon)
        {
            return None;
        }

        // Find the point of intersection of the line with the circle
        var a = -(c + Math.sqrt(sigma));

        // Is the intersection of the line with the circle
        if(0.0 <= a && a <= input.maxFraction * rr)
        {
            a /= rr;
            var normal = s + a * r;
            return Some(new RayCastOutput(normal.normalize(), a));
        }

        return None;
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
