package nengine.math.planeSweep;
import nengine.ds.*;
import nengine.physics.collision.Collision;

using nengine.math.planeSweep.EventFunction;

class PlaneSweepIntersectionDetector implements IntersectionDetector
{
    private var sweepLine = new Line2(0, -1, 0);
    private var belowLine = new Line2(0, -1, 0.1);

    public function execute(segments:Array<Segment2>):Array<Intersection>
    {
        // TODO:rbtreeはimmutableなのでそのへんでミスがないか調べる
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

        var result:Array<Intersection> = [];

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
                    left.iter((left)->{
                        eventQueue = checkIntersection(left, segment1, sweepY, eventQueue);
                    });
                    // 右隣の線分との交差を調べる
                    right.iter((right)->{
                        eventQueue = checkIntersection(segment1, right, sweepY, eventQueue);
                    });
                case Some(Intersection(point, segment1, segment2)):
                    var sweepY = point.y;
                    var left = segment1;
                    var right = segment2;
                    // 交点返値に追加
                    result.push(new Intersection(left, right));

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
                    moreLeft.iter((moreLeft)->{
                        eventQueue = checkIntersection(moreLeft, right, sweepY, eventQueue);
                    });
                    // left(今は右側)と更に右側の線分との交差を調べる
                    moreRight.iter((moreRight)->{
                        eventQueue = checkIntersection(left, moreRight, sweepY, eventQueue);
                    });
                case Some(SegmentEnd(point, segment1)):
                    var sweepY = point.y;
                    var left = status.lower(segment1);
                    var right = status.higher(segment1);

                    // 線分の削除によって新しく隣り合う2線分の交差を調べる
                    left.iter((left)->{
                    right.iter((right)->{
                        eventQueue = checkIntersection(left, right, sweepY, eventQueue);
                    });
                    });
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
        // TODO:resultの要素の重複を取り除く
        return result;
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
