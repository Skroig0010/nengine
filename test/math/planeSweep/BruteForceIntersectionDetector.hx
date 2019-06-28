package test.math.planeSweep;
import nengine.ds.*;
import nengine.physics.collision.Collision;
import nengine.math.*;
import nengine.math.planeSweep.*;

class BruteForceIntersectionDetector
{
    public function new() {}
    public function execute(segments:Array<Segment2>):Array<Intersection>
    {
        var result = new Array<Intersection>();
        for(index1 in 0...segments.length)
        {
            for(index2 in index1 + 1...segments.length)
            {
                var point = Collision.getSegmentsIntersectionPoint(segments[index1], segments[index2]);
                switch(point)
                {
                    case Some(p):
                        result.push(new Intersection(segments[index1], segments[index2]));
                    case None:
                }
            }
        }
        return result;
    }
}
