package nengine.math;

class Segment2
{
    public var vertex1:Vec2;
    public var vertex2:Vec2;

    public function new(vertex1:Vec2, vertex2:Vec2)
    {
        this.vertex1 = vertex1;
        this.vertex2 = vertex2;
    }

    public static inline function toLine(segment:Segment2):Line2
    {
        return Line2.fromPoints(segment.vertex1, segment.vertex2);
    }
}
