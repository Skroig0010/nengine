package nengine.physics.collision.shapes;
import nengine.math.*;

class CircleShape2 implements Shape2
{
    public var type(default, never) = Shape2Type.Circle;
    public var radius:Float;
    public var position:Vec2;
    public var childCount(get, never):Int;

    public function new(?position:Vec2, ?radius:Float)
    {
        this.position = if(position != null) position else new Vec2();
        this.radius = if(radius != null) radius else 0;
    }

    public function testPoint(transform:Transform2, point:Vec2):Bool
    {
        var center = transform * position;
        var d = point - center;
        return d.dot(d) <= radius * radius;
    }

    public function computeAABB(transform:Transform2):AABB2
    {
        var p = transform * position;
        return new AABB2(new Vec2(p.x - radius, p.y - radius),
                new Vec2(p.x + radius, p.y + radius));
    }

    public function computeMass(density:Float):MassData
    {
        var mass =  density * Math.PI * radius * radius;
        return {
            mass:mass,
            centeroid:position,
            inertia:mass * (0.5 * radius * radius + position.dot(position)),
        };
    }

    private function get_childCount():Int
    {
        return 1;
    }
}
