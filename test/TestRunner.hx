package test;
import utest.Runner;
import utest.ui.Report;
import test.util.*;
import test.components.shapes.*;
import test.math.*;
import test.math.planeSweep.*;
import test.physics.collision.*;

class TestRunner
{
    public static function main()
    {
        var r = new Runner();
        r.addCase(new ShapeTest());
        r.addCase(new QuadTreeTest());
        r.addCase(new RedBlackTreeTest());
        r.addCase(new PlaneSweepIntersectionDetectorTest());
        r.addCase(new PolygonIntersectionTest());
        r.addCase(new CollisionTest());
        // r.addCase(new ConvexHullIntersectionTest());
        Report.create(r);
        r.run();
    }
}
