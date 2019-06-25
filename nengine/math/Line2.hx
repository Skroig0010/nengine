package nengine.math;

class Line2
{
    public var a:Float;
    public var b:Float;
    public var c:Float;

    public function new(a:Float, b:Float, c:Float)
    {
        this.a = a;
        this.b = b;
        this.c = c;
    }

    public static inline function fromPoints(p1:Vec2, p2:Vec2):Line2
    {
        var p = p2 - p1;
        return new Line2(p.y, -p.x, p.x * p1.y - p.y * p1.x);
    }
}
