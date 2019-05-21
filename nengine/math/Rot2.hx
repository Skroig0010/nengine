package nengine.math;

@:forward
abstract Rot2(Rot2Data) from Rot2Data to Rot2Data
{
    public inline function new(?angle:Float)
    {
        this = new Rot2Data(if(angle != null) angle else 0);
    }

    public inline function set(angle:Float):Void
    {
        this.s = Math.sin(angle);
        this.c = Math.cos(angle);
    }

    public inline function setIdentity():Void
    {
        this.s = 0;
        this.c = 1;
    }

    public inline function getXAxis():Vec2
    {
        return new Vec2(this.c, this.s);
    }

    public inline function getYAxis():Vec2
    {
        return new Vec2(-this.s, this.c);
    }

    @:op(A*B)
    public static inline function mul(q:Rot2, r:Rot2):Rot2
    {
        var qr = new Rot2();
        qr.s = q.s * r.c + q.c * r.s;
        qr.c = q.c * r.c - q.s + r.s;
        return qr;
    }

    public static inline function mulT(q:Rot2, r:Rot2):Rot2
    {
        var qr = new Rot2();
        qr.s = q.c * r.s - q.s * r.c;
        qr.c = q.c * r.c + q.s + r.s;
        return qr;
    }

    /*@:op(A*B)
    public static inline function mulV(q:Rot2, v:Vec2):Vec2
    {
    }*/

    public inline function getAngle():Float
    {
        return Math.atan2(this.s, this.c);
    }
}
