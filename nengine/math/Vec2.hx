package nengine.math;

@:forward
abstract Vec2(Vec2Data) from Vec2Data to Vec2Data
{

    public inline function new(?x:Float, ?y:Float)
    {
        this = new Vec2Data(
                if(x != null)x else 0,
                if(y != null)y else 0);
    }

    public inline function length() return Math.sqrt(this.x*this.x + this.y*this.y);

    public inline function setZero():Void
    {
        this.x = 0;
        this.y = 0;
    }

    public inline function setV(v:Vec2):Void
    {
        this.x = v.x;
        this.y = v.y;
    }

    public inline function copy():Vec2
    {
        return new Vec2(this.x, this.y);
    }

    public inline function normalize():Vec2
    {
        var l = length();
        return new Vec2(this.x/l, this.y/l);
    }

    public inline function abs():Vec2
    {
        return new Vec2(Math.abs(this.x), Math.abs(this.y));
    }

    @:op(-A) 
    public static inline function minus(v:Vec2):Vec2
    {
        return new Vec2(-v.x, -v.y);
    }

    @:op(A+B)
    public static inline function add(v1:Vec2, v2:Vec2):Vec2
    {
        return new Vec2(v1.x + v2.x, v1.y + v2.y);
    }

    @:op(A-B) 
    public static inline function sub(v1:Vec2, v2:Vec2):Vec2
    {
        return new Vec2(v1.x - v2.x, v1.y - v2.y);
    }

    @:op(A*B)
    public static inline function mulScalar1(v:Vec2, f:Float):Vec2
    {
        return new Vec2(f * v.x, f * v.y);
    }

    @:op(A*B)
    public static inline function mulScalar2(f:Float, v:Vec2):Vec2
    {
        return Vec2.mulScalar1(v, f);
    }

    @:op(A*B)
    public static inline function rotVec(q:Rot2, v:Vec2):Vec2
    {
        return new Vec2(q.c * v.x - q.s * v.y, q.s * v.x + q.c * v.y);
    }

    public static inline function rotVecT(q:Rot2, v:Vec2):Vec2
    {
        return new Vec2(q.c * v.x + q.s * v.y, -q.s * v.x + q.c * v.y);
    }

    @:op(A==B)
    public static inline function equals(v1:Vec2, v2:Vec2):Bool
    {
        return v1.x == v2.x && v1.y == v2.y;
    }

    public static inline function min(a:Vec2, b:Vec2):Vec2
    {
        return new Vec2(Math.min(a.x, b.x), Math.min(a.y, b.y));
    }

    public static inline function max(a:Vec2, b:Vec2):Vec2
    {
        return new Vec2(Math.max(a.x, b.x), Math.max(a.y, b.y));
    }

    public inline function dot(v:Vec2)return this.x * v.x + this.y * v.y;

    public inline function cross(v:Vec2)return this.x * v.y - this.y * v.x;

    public static inline function crossVF(v:Vec2, f:Float)return new Vec2(f * v.y, -f * v.x);

    public static inline function crossFV(f:Float, v:Vec2)return new Vec2(-f * v.y, f * v.x);
}
