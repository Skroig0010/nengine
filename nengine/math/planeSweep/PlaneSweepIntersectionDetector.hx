package nengine.math.planeSweep;
import nengine.ds.*;
import nengine.physics.collision.Collision;

using nengine.math.planeSweep.EventFunction;

class PlaneSweepIntersectionDetector implements IntersectionDetector
{
    private var sweepLine = new Line2(0, -1, 0);
    private var belowLine = new Line2(0, -1, 0.1);

    public function new()
    {
        setY(0);
    }

    public function execute(segments:Array<Segment2>):Array<Intersection>
    {
        var eventQueue = new RedBlackTree<Event>(Comparator.compareEvent);

        for(segment in segments)
        {
            if(segment.vertex1.y < segment.vertex2.y ||
                    (segment.vertex1.y == segment.vertex2.y && segment.vertex1.x < segment.vertex2.x))
            {
                eventQueue = eventQueue.add(SegmentStart(segment.vertex1, segment));
                eventQueue = eventQueue.add(SegmentEnd(segment.vertex2, segment));
            }
            else
            {
                eventQueue = eventQueue.add(SegmentStart(segment.vertex2, segment));
                eventQueue = eventQueue.add(SegmentEnd(segment.vertex1, segment));
            }
        }

        var status = new RedBlackTree<Segment2>(Comparator.compareLineSegmentBySweepLine.bind(sweepLine, belowLine));

        var result = new HashSet<Intersection>();

        var event = eventQueue.first();
        switch(event)
        {
            case Some(e):
                eventQueue = eventQueue.remove(e);
            case None:
        }

        while(true)
        {
            switch(event)
            {
                case Some(SegmentStart(point, segment1)):
                    var sweepY = point.y;
                    setY(sweepY);
                    status = status.add(segment1);

                    var left = status.lower(segment1);
                    var right = status.higher(segment1);
                    // 左隣の線分との交差を調べる
                    switch(left)
                    {
                        case Some(left):
                            eventQueue = checkIntersection(left, segment1, sweepY, eventQueue);
                        case None:
                    }
                    // 右隣の線分との交差を調べる
                    switch(right)
                    {
                        case Some(right):
                            eventQueue = checkIntersection(segment1, right, sweepY, eventQueue);
                        case None:
                    }
                case Some(Intersection(point, segment1, segment2)):
                    var sweepY = point.y;
                    var left = segment1;
                    var right = segment2;
                    // 交点返値に追加
                    result.add(new Intersection(left, right));

                    var moreLeft = status.lower(left);
                    var moreRight = status.higher(right);

                    // ステータス中のleftとrightの位置を交換するため、一旦削除する
                    status = status.remove(left);
                    status = status.remove(right);
                    setY(sweepY+0.001);
                    // 更新後の走査線を基準にleftとrightを再追加して位置交換
                    status = status.add(left);
                    status = status.add(right);

                    // right(今は左側)と更に左側の線分との交差を調べる
                    switch(moreLeft)
                    {
                        case Some(moreLeft):
                            eventQueue = checkIntersection(moreLeft, right, sweepY, eventQueue);
                        case None:
                    }
                    // left(今は右側)と更に右側の線分との交差を調べる
                    switch(moreRight)
                    {
                        case Some(moreRight):
                            eventQueue = checkIntersection(left, moreRight, sweepY, eventQueue);
                        case None:
                    }
                case Some(SegmentEnd(point, segment1)):
                    var sweepY = point.y;
                    var left = status.lower(segment1);
                    var right = status.higher(segment1);

                    // 線分の削除によって新しく隣り合う2線分の交差を調べる
                    switch([left, right])
                    {
                        case [Some(left), Some(right)]:
                            eventQueue = checkIntersection(left, right, sweepY, eventQueue);
                        default:
                    }
                    status = status.remove(segment1);
                    setY(sweepY);
                case None:
                    break;
            }
            event = eventQueue.first();
            switch(event)
            {
                case Some(e):
                    eventQueue = eventQueue.remove(e);
                case None:
            }
        }
        return Lambda.array(result);
    }

    // leftとrightが走査線の下で交差するか調べ、交差する場合は交差イベントを登録
    private function checkIntersection(
            left:Segment2, right:Segment2, sweepY:Float, eventQueue:RedBlackTree<Event>):RedBlackTree<Event>
    {
        var point = Collision.getSegmentsIntersectionPoint(left, right);
        return switch(point)
        {
            case Some(p) if(p.y >= sweepY):
                eventQueue.add(Event.Intersection(p, left, right));
            default:
                eventQueue;
        }
    }

    private function setY(y:Float):Void
    {
        sweepLine.c = y;
        belowLine.c = y + 0.1;
    }
}

private class HashSet<T: { }> implements Set<T>
{
    private var map = new Map<T, Int>();

    public function new(){}

    public function add(element:T):Set<T>
    {
        map.set(element, 0);
        return this;
    }

    public function remove(element:T):Set<T>
    {
        map.remove(element);
        return this;
    }

    public function has(element:T):Bool
    {
        return map.exists(element);
    }

    public function iterator():Iterator<T>
    {
        return map.keys();
    }
}
