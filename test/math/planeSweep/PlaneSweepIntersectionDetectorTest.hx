package test.math.planeSweep;
import utest.Test;
import utest.Assert;
import haxe.ds.Option;
import nengine.math.*;
import nengine.math.planeSweep.*;

@:access(nengine.math.planeSweep.PlaneSweepIntersectionDetector)
class PlaneSweepIntersectionDetectorTest extends Test
{
    public function testExecute()
    {
        var segments = new Array<Segment2>();
        segments.push(new Segment2(new Vec2(1, 0), new Vec2(1, 2)));
        segments.push(new Segment2(new Vec2(0, 1), new Vec2(2, 1)));
        // segments.push(new Segment2(new Vec2(5, 1), new Vec2(5, 2)));
        // segments.push(new Segment2(new Vec2(5, -1), new Vec2(5, 2)));
        segments.push(new Segment2(new Vec2(0, 0), new Vec2(5, 5)));

        var sweep = new PlaneSweepIntersectionDetector();
        var brute = new BruteForceIntersectionDetector();

        var sweepResult = sweep.execute(segments);
        var bruteResult = brute.execute(segments);

        Assert.equals(sweepResult.length, bruteResult.length);

        for(res1 in sweepResult)
        {
            Assert.isTrue(Lambda.exists(bruteResult, (res2) -> checkSameIntersection(res1, res2)));
        }
    }

    private function checkSameIntersection(inter1:Intersection, inter2:Intersection):Bool
    {
        return (checkSameSegment(inter1.segment1, inter2.segment1) && checkSameSegment(inter1.segment2, inter2.segment2))
            || (checkSameSegment(inter1.segment1, inter2.segment2) && checkSameSegment(inter1.segment2, inter2.segment1));
    }

    private function checkSameSegment(seg1:Segment2, seg2:Segment2):Bool
    {
        return (checkSameVec2(seg1.vertex1, seg2.vertex1) && checkSameVec2(seg1.vertex2, seg2.vertex2))
            || (checkSameVec2(seg1.vertex1, seg2.vertex2) && checkSameVec2(seg1.vertex2, seg2.vertex1));
    }

    private function checkSameVec2(v1:Vec2, v2:Vec2):Bool
    {
        return v1.x == v2.x && v1.y == v2.y;
    }

}
