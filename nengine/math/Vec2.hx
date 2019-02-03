package nengine.math;

@:forward
abstract Vec2(Vec2Data) from Vec2Data to Vec2Data
{

    public inline function new(x:Float, y:Float)this = new Vec2Data(x,y);

    public inline function length() return Math.sqrt(this.x*this.x + this.y*this.y);

    public inline function normalize():Vec2
    {
        var l = length();
        return new Vec2(this.x/l, this.y/l);
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

    @:op(A==B)
    public static inline function equals(v1:Vec2, v2:Vec2):Bool
    {
        return v1.x == v2.x && v1.y == v2.y;
    }

    public inline function dot(v:Vec2)return this.x * v.x + this.y * v.y;

    public inline function cross(v:Vec2)return this.x * v.y - this.y * v.x;
}

