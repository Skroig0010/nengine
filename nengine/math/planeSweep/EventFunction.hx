package nengine.math.planeSweep;

class EventFunction
{
    public static function getPoint(event:Event):Vec2
    {
        return switch(event)
        {
            case SegmentStart(point, _)
            | SegmentEnd(point, _)
            | Intersection(point, _, _):
                point;
        }
    }

    public static function getSegment1(event:Event):Segment2
    {
        return switch(event)
        {
            case SegmentStart(_, segment1)
            | SegmentEnd(_, segment1)
            | Intersection(_, segment1, _):
                segment1;
        }
    }
}
