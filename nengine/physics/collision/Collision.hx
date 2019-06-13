package nengine.physics.collision;
import nengine.physics.collision.shapes.*;
import nengine.math.*;

class Collision
{
    public static var maxManifoldPoints(default, never) = 2;

    public static inline function collideAABBs(aabbA:AABB2, aabbB:AABB2):Bool
    {
        return aabbA.upperBound.x < aabbB.lowerBound.x
            && aabbA.upperBound.y < aabbB.lowerBound.y
            && aabbB.upperBound.x < aabbA.lowerBound.x
            && aabbB.upperBound.y < aabbA.lowerBound.y;
    }

    public static function collideSegments(segmentA:Segment2, segmentB:Segment2):Option<Vec2>
    {
        var vA = segmentA.vertex2 - segmentA.vertex1;
        var vB = segmentB.vertex2 - segmentB.vertex1;
        var v1 = segmentB.vertex1 - segmentA.vertex1;

        var crossAB = vA.cross(vB);
        // 平行
        if(crossAB == 0.0)
        {
            return None;
        }

        var cross1A = v1.cross(vA);
        var cross1B = v1.cross(vB);

        var t1 = cross1B/crossAB;
        var t2 = cross1A/crossAB;

        if(t1 + Settings.epsilon < 0 || t1 - Settings.epsilon > 1 || t2 + Settings.epsilon < 0 || t2 - Settings.epsilon > 1)
        {
            // 交差してない
            return None;
        }
        
        return Some(segmentA.vertex1 + vA * t1);
    }

    public static inline function getNextIndex(index:Int, length:Int):Int
    {
        return if(index + 1 < length) index + 1 else 0;
    }
}
