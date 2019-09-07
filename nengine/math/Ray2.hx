package nengine.math;

class Ray2
{
    public var origin:Vec2;
    // dirは基本的に正規化されていない
    public var dir:Vec2;

    public function new(origin:Vec2, dir:Vec2)
    {
        this.origin = origin;
        this.dir = dir;
    }
}
