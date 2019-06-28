package test;
import utest.Runner;
import utest.ui.Report;
import test.util.*;
import test.components.shapes.*;
import test.math.*;
import test.math.planeSweep.*;

class TestRunner
{
    public static function main()
    {
        var r = new Runner();
        r.addCase(new ShapeTest());
        r.addCase(new QuadTreeTest());
        r.addCase(new RedBlackTreeTest());
        r.addCase(new PlaneSweepIntersectionDetectorTest());
        Report.create(r);
        r.run();
    }
}
