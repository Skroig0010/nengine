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

    public static function getSegmentsIntersectionPoint(segmentA:Segment2, segmentB:Segment2):Option<Vec2>
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

    public static function getLinesIntersectionPoint(line1:Line2, line2:Line2):Option<Vec2>
    {
        var d = line1.a * line2.b - line2.a * line1.b;
        return if(d == 0.0)
        {
            None;
        }
        else
        {
            var x = (line1.b * line2.c - line1.c * line2.b) / d;
            var y = (line1.a * line2.c - line1.c * line2.a) / d;
            return Some(new Vec2(x, y));
        }
    }

    public static inline function getLineAndSegmentIntersectionPoint(line1:Line2, segment2:Segment2):Option<Vec2>
    {
        return if(!collideLineAndSegment(line1, segment2))
        {
            None;
        }
        else
        {
            getLinesIntersectionPoint(line1, Segment2.toLine(segment2));
        }
    }

    public static inline function collideLineAndSegment(line1:Line2, segment2:Segment2):Bool
    {
        var t1 = line1.a * segment2.vertex1.x + line1.b * segment2.vertex1.y + line1.c;
        var t2 = line1.a * segment2.vertex2.x + line1.b * segment2.vertex2.y + line1.c;
        return t1 * t2 <= 0;
    }

    public static inline function collideSegments(segment1:Segment2, segment2:Segment2):Bool
    {
        return collideLineAndSegment(Segment2.toLine(segment1), segment2)
            && collideLineAndSegment(Segment2.toLine(segment2), segment1);
    }

    public static inline function getNextIndex(index:Int, length:Int):Int
    {
        return if(index + 1 < length) index + 1 else 0;
    }
}
