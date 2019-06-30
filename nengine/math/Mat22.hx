package nengine.math;

@:forward
abstract Mat22(Mat22Data) from Mat22Data to Mat22Data
{
    public inline function new(?c1:Vec2, ?c2:Vec2)
    {
        this = new Mat22Data(
                if(c1 != null) c1 else new Vec2(0, 0),
                if(c2 != null) c2 else new Vec2(0, 0)
                );
    }

    public inline function setIdentity():Void
    {
        this.c1.x = 1.0;
        this.c2.x = 0.0;
        this.c1.y = 0.0;
        this.c2.y = 1.0;
    }

    public inline function setZero():Void
    {
        this.c1.x = 0.0;
        this.c2.x = 0.0;
        this.c1.y = 0.0;
        this.c2.y = 0.0;
    }

    public inline function getInverse():Mat22
    {
        var a = this.c1.x, b = this.c2.x, c = this.c1.y, d = this.c2.y;
        var det = a * d - b * c;
        if(det != 0.0)
        {
            det = 1.0 / det;
        }
        return new Mat22(
                new Vec2(det * d, -det * b),
                new Vec2(-det * c, det * a));
    }

    @:op(A*B)
    public static inline function mulV(m:Mat22, v:Vec2):Vec2
    {
        return new Vec2(m.c1.x * v.x + m.c2.x * v.y, m.c1.y * v.x + m.c2.y * v.y);
    }

    public inline function solve(v:Vec2):Vec2
    {
        var a = this.c1.x, b = this.c2.x, c = this.c1.y, d = this.c2.y;
        var det = a * d - b * c;
        if(det != 0.0)
        {
            det = 1.0 / det;
        }
        return new Vec2(
                det * (d * v.x - b * v.y),
                det * (a * v.y - c * v.x));
    }
}
