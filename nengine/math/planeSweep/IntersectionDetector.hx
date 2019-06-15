package nengine.math.planeSweep;

interface IntersectionDetector
{
    public function execute(segments:Array<Segment2>):Array<Intersection>;
}
