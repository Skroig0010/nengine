package nengine.physics.collision.shapes;
import ecs.Component;
import ecs.Entity;
import nengine.math.*;

class AABB2 
{
    // スクリーン座標系
    public var upperBound:Vec2;
    public var lowerBound:Vec2;

    public function new(upperBound:Vec2, lowerBound:Vec2)
    {
        this.lowerBound = lowerBound;
        this.upperBound = upperBound;
    }

    public function isValid():Bool
    {
        var d = lowerBound - upperBound;
        return d.x >= 0.0 && d.y >= 0.0;
    }

    public function getCenter():Vec2
    {
        return 0.5 * (lowerBound + upperBound);
    }

    public function getExtents():Vec2
    {
        return 0.5 * (lowerBound - upperBound);
    }

    public function getPerimeter():Float
    {
        var wx = lowerBound.x - upperBound.x;
        var wy = lowerBound.y - upperBound.y;
        return 2 * (wx + wy);
    }

    public function combines(aabb:AABB2):Void
    {
        upperBound = Vec2.min(upperBound, aabb.upperBound);
        lowerBound = Vec2.max(lowerBound, aabb.lowerBound);
    }

    public static function combine(aabb1:AABB2, aabb2:AABB2):AABB2
    {
        return new AABB2(
                Vec2.min(aabb1.upperBound, aabb2.upperBound),
                Vec2.max(aabb1.lowerBound, aabb2.lowerBound));
    }

    public function contains(aabb:AABB2):Bool
    {
        return upperBound.x <= aabb.upperBound.x
            && upperBound.y <= aabb.upperBound.y
            && aabb.lowerBound.x <= lowerBound.x
            && aabb.lowerBound.y <= lowerBound.y;
    }

    public static inline function testOverlap(a:AABB2, b:AABB2):Bool
    {
        var d1 = b.upperBound - a.lowerBound;
        var d2 = a.upperBound - b.lowerBound;

        return !(d1.x > 0 || d1.y > 0 || d2.x > 0 || d2.y > 0);
    }


}
