package nengine.math.planeSweep;
import nengine.physics.collision.Collision;

class Intersection
{
    public var segment1:Segment2;
    public var segment2:Segment2;

    public function new(segment1:Segment2, segment2:Segment2)
    {
        this.segment1 = segment1;
        this.segment2 = segment2;
    }

    public function getIntersectionPoint():Option<Vec2>
    {
        return Collision.getSegmentsIntersectionPoint(segment1, segment2);
    }
}
