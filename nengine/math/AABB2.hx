package nengine.math;

class AABB2
{
    public var upperBound(default, null):Vec2;
    public var lowerBound(default, null):Vec2;

    public function new(upperBound:Vec2, lowerBound:Vec2)
    {
        this.upperBound = upperBound;
        this.lowerBound = lowerBound;
    }
}
