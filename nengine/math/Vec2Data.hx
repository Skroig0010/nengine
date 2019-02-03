package nengine.math;

class Vec2Data{
    public var x:Float;
    public var y:Float;

    public function new(x:Float, y:Float)
    {
        this.x = x;
        this.y = y;
    }

    public inline function iterator()
    {
        return [this.x, this.y].iterator();
    }
}
