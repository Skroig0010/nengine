package test.math.planeSweep;
import utest.Test;
import utest.Assert;
import haxe.ds.Option;
import nengine.math.*;
import nengine.math.planeSweep.*;

@:access(nengine.math.planeSweep.PolygonIntersection)
class PolygonIntersectionTest extends Test
{
    public function testExecute()
    {
        var v1 = new Vec2(0, 0);
        var v2 = new Vec2(1, 0);
        var v3 = new Vec2(0, 1);
        var v4 = new Vec2(1, 1);
        var v5 = new Vec2(0.5, 0.5);
        // ⊿
        var a = new ConvexHull2([v1, v2, v4]);
        // ⊿ の左右逆
        var b = new ConvexHull2([v1, v2, v3]);
        // □
        var c = new ConvexHull2([v1, v2, v4, v3]);

        // 同じ図形
        switch(PolygonIntersection.execute(a, a))
        {
            case Some(actual):
                isSame(a, actual);
            case None:
                Assert.isTrue(false);
        }

        // 同じ辺を共有する図形
        var expected = new ConvexHull2([v1, v2, v5]);
        switch(PolygonIntersection.execute(a, b))
        {
            case Some(actual):
                isSame(expected, actual);
            case None:
                Assert.isTrue(false);
        }

        // 片方がもう片方を内包するような図形
        switch(PolygonIntersection.execute(a, c))
        {
            case Some(actual):
                isSame(new ConvexHull2([v1, v2, v4]), actual);
            case None:
                Assert.isTrue(false);
        }
    }

    private function isSame(convA:ConvexHull2, convB:ConvexHull2):Void
    {
        Assert.equals(convA.vertices.length, convB.vertices.length);
        if(convA.vertices.length != convB.vertices.length) return;
        for(index in 0...convA.vertices.length)
        {
            Assert.equals(convA.vertices[index].x, convB.vertices[index].x);
            Assert.equals(convA.vertices[index].y, convB.vertices[index].y);
        }
    }
}
