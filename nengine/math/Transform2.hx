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
}
