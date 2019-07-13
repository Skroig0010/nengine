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

    public function combine(other:AABB2):AABB2
    {
        return new AABB2(Vec2.min(upperBound, other.upperBound), Vec2.max(lowerBound, other.lowerBound));
    }

    public function contains(other:AABB2):Bool
    {
        return upperBound.x <= other.upperBound.x
            && upperBound.y <= other.upperBound.y
            && other.lowerBound.x <= lowerBound.x
            && other.lowerBound.y <= lowerBound.y;
    }

    public function containsV(v:Vec2):Bool
    {
        return upperBound.x <= v.x 
            && upperBound.y <= v.y
            && v.x <= lowerBound.x
            && v.y <= lowerBound.y;
    }
}
