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
        if(crossAB < Settings.epsilon && crossAB > -Settings.epsilon)
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

    public static function getRayAndSegmentIntersectionPoint(rayA:Ray2, segmentB:Segment2):Option<Vec2>
    {
        var vA = rayA.dir;
        var vB = segmentB.vertex2 - segmentB.vertex1;
        var v1 = segmentB.vertex1 - rayA.origin;

        var crossAB = vA.cross(vB);
        // 平行
        if(crossAB < Settings.epsilon && crossAB > -Settings.epsilon)
        {
            return None;
        }

        var cross1A = v1.cross(vA);
        var cross1B = v1.cross(vB);

        var t1 = cross1B/crossAB;
        var t2 = cross1A/crossAB;

        if(t1 + Settings.epsilon < 0 || t2 + Settings.epsilon < 0 || t2 - Settings.epsilon > 1)
        {
            // 交差してない
            return None;
        }
        
        return Some(rayA.origin + vA * t1);
    }

    public static function getLinesIntersectionPoint(lineA:Line2, lineB:Line2):Option<Vec2>
    {
        var d = lineA.a * lineB.b - lineB.a * lineA.b;
        return if(d < Settings.epsilon && d > -Settings.epsilon)
        {
            None;
        }
        else
        {
            var x = (lineA.b * lineB.c - lineA.c * lineB.b) / d;
            var y = (lineA.a * lineB.c - lineA.c * lineB.a) / d;
            return Some(new Vec2(x, y));
        }
    }

    public static inline function getLineAndSegmentIntersectionPoint(lineA:Line2, segmentB:Segment2):Option<Vec2>
    {
        return if(collideLineAndSegment(lineA, segmentB))
        {
            getLinesIntersectionPoint(lineA, Segment2.toLine(segmentB));
        }
        else
        {
            None;
        }
    }

    public static inline function collideLineAndSegment(lineA:Line2, segmentB:Segment2):Bool
    {
        var t1 = lineA.a * segmentB.vertex1.x + lineA.b * segmentB.vertex1.y + lineA.c;
        var t2 = lineA.a * segmentB.vertex2.x + lineA.b * segmentB.vertex2.y + lineA.c;
        return t1 * t2 <= 0;
    }

    public static function collideSegments(segmentA:Segment2, segmentB:Segment2):Bool
    {
        return bothSidesSegment(segmentA, segmentB) && bothSidesSegment(segmentB, segmentA);
    }

    private static function bothSidesSegment(segmentA:Segment2, segmentB:Segment2):Bool
    {
        var ccw1 = Vec2.ccw(segmentA.vertex1, segmentB.vertex1, segmentA.vertex2);
        var ccw2 = Vec2.ccw(segmentA.vertex1, segmentB.vertex2, segmentA.vertex2);

        return if(ccw1 == 0 && ccw2 == 0)
        {
            internal(segmentA, segmentB.vertex1) || internal(segmentA, segmentB.vertex2);
        }
        else
        {
            ccw1 * ccw2 <= 0;
        }

    }

    private static inline function internal(segment:Segment2, vertex:Vec2):Bool
    {
        return (segment.vertex1 - vertex).dot(segment.vertex2 - vertex) <= 0;
    }

    public static inline function getNextIndex(index:Int, length:Int):Int
    {
        return if(index + 1 < length) index + 1 else 0;
    }

    public static function convexContains(conv:ConvexHull2, vertex:Vec2):Bool
    {
        var vertices = conv.vertices;
        var size = vertices.length;
        // center of gravity
        var g = (vertices[0] + vertices[Std.int(size / 3)] + vertices[Std.int(2 * size / 3)]) / 3;
        var a = 0;
        var b = size;
        while(a + 1 < b)
        {
            var c = Std.int((a + b) / 2);
            var ag = vertices[a] - g;
            var cg = vertices[c] - g;
            var pg = vertex - g;

            // angle < 180 deg
            if(ag.cross(cg) > 0)
            {
                if(ag.cross(pg) > 0 && cg.cross(pg) < 0)
                {
                    b = c;
                }
                else
                {
                    a = c;
                }
            }
            else
            {
                if(ag.cross(pg) < 0 && cg.cross(pg) > 0)
                {
                    a = c;
                }
                else
                {
                    b = c;
                }
            }
        }

        b %= size;

        if((vertices[a] - vertex).cross(vertices[b] - vertex) < 0) return false;
        return true;
    }
}
