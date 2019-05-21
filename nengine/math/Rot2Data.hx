package nengine.math;

class Rot2Data
{
    public var s:Float;
    public var c:Float;
    public var a:Float;

    public function new(angle:Float)
    {
        s = Math.sin(angle);
        c = Math.cos(angle);
    }

    public inline function iterator()
    {
        return [this.s, this.c].iterator();
    }
}
