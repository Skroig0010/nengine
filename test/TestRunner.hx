package test;
import utest.Runner;
import utest.ui.Report;
import test.util.*;
import test.components.shapes.*;

class TestRunner
{
    public static function main()
    {
        var r = new Runner();
        r.addCase(new ShapeTest());
        r.addCase(new QuadTreeTest());
        Report.create(r);
        r.run();
    }
}
