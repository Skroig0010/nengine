package nengine.math.planeSweep;
import nengine.physics.collision.Collision;

class Comparator
{
    public static function compareEvent(event1:Event, event2:Event):Int
    {
        var point1 = getPoint(event1);
        var point2 = getPoint(event2);
        return Std.int(if(point1.y != point2.y)
        {
            point1.y - point2.y;
        }
        else
        {
            point1.x - point2.x;
        });
    }

    private static inline function getPoint(event:Event):Vec2
    {
        return switch(event)
        {
            case SegmentStart(point, _)
            | SegmentEnd(point, _)
            | Intersection(point, _, _):
                point;
        }
    }

    public static function compareLineSegmentBySweepLine(sweepLine:Line2, belowLine:Line2, seg1:Segment2, seg2:Segment2):Int
    {
        var comp = compareByLine(sweepLine, seg1, seg2);
        if(comp == 0)
        {
            comp = compareByLine(belowLine, seg1, seg2);
        }
        return comp;
    }

    private static function compareByLine(line:Line2, seg1:Segment2, seg2:Segment2):Int
    {
        var p1 = Collision.getLinesIntersectionPoint(Segment2.toLine(seg1), line);
        var p2 = Collision.getLinesIntersectionPoint(Segment2.toLine(seg2), line);

        var x1 = switch(p1)
        {
            case Some(v):
                v.x;
            case None:
                seg1.vertex1.x;
        }
        var x2 = switch(p2)
        {
            case Some(v):
                v.x;
            case None:
                seg2.vertex1.x;
        }

        return Std.int(x1 - x2);
    }
}
