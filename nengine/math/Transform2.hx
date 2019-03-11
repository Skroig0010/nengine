package nengine.math;

@:forward
abstract Transform2(Transform2Data) from Transform2Data to Transform2Data
{
    public inline function new(?position:Vec2, ?rotation:Rot2)
    {
        this = new Transform2Data(
                if(position != null)position else new Vec2(),
                if(rotation != null)rotation else new Rot2());
    }

    @:op(A*B)
    public static inline function mulX(t:Transform2, v:Vec2):Vec2
    {
        return t.rotation * v + t.position;
    }

    public static inline function mulXT(t:Transform2, v:Vec2):Vec2
    {
        return Vec2.rotVecT(t.rotation, v - t.position);
    }

    @:op(A*B)
    public static inline function mul(t1:Transform2, t2:Transform2):Transform2
    {
        return new Transform2(
                t1.rotation * t2.position + t1.position,
                t1.rotation * t2.rotation);
    }

    public static inline function mulT(t1:Transform2, t2:Transform2):Transform2
    {
        return new Transform2(
                t1.rotation * (t2.position - t1.position),
                t1.rotation * t2.rotation);
    }
}
