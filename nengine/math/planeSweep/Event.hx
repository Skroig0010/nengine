package nengine.math.planeSweep;

enum Event
{
    SegmentStart(point:Vec2, segment1:Segment2);
    SegmentEnd(point:Vec2, segment1:Segment2);
    Intersection(point:Vec2, segment1:Segment2, segment2:Segment2);
}
