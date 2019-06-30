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

    public static inline function fromVectors(p1:Vec2, p2:Vec2):Line2
    {
        var p = p2 - p1;
        return new Line2(p.y, -p.x, p.x * p1.y - p.y * p1.x);
    }

    public static inline function fromPoints(px1:Float, py1:Float, px2:Float, py2:Float):Line2
    {
        var px = px2 - px1;
        var py = py2 - py1;
        return new Line2(py, -px, px * py1 - py * px1);
    }
}
