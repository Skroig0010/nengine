package nengine.math.planeSweep;
import nengine.ds.*;

interface IntersectionDetector
{
    public function execute(segments:Array<Segment2>):Array<Intersection>;
}
