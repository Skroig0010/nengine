package nengine.math.planeSweep;
import nengine.physics.collision.Collision;

class PolygonIntersection
{
    public static function execute(convA:ConvexHull2, convB:ConvexHull2):Option<ConvexHull2>
    {
        // 凸多角形の左右辺リスト
        // それっぽく縮める
        // 広げると左辺右辺で衝突しなくなってしまう
        // なんとかならないのか
        var status = {
            left1:0,
            lefts1:createSegmentsArray(convA, Side.Left, new Vec2(0.0000001, -0.0000001)),
            right1:0,
            rights1:createSegmentsArray(convA, Side.Right, new Vec2(-0.0000001, -0.0000001)),
            left2:0,
            lefts2:createSegmentsArray(convB, Side.Left, new Vec2(0.0000001, 0.0000001)),
            right2:0,
            rights2:createSegmentsArray(convB, Side.Right, new Vec2(-0.0000001, 0.0000001)),
        }
        var leftResult = new Array<Segment2>();
        var rightResult = new Array<Segment2>();
        // trace('\nleft1: ${status.lefts1}');
        // trace('\nleft2: ${status.lefts2}');
        // trace('\nright1: ${status.rights1}');
        // trace('\nright2: ${status.rights2}');


        // 最初のイベント取得
        var result = firstPass(status, leftResult, rightResult);
        while(Type.enumEq(result, Yes))
        {
            // 2番目以降のイベントの処理
            result = secondPass(status, leftResult, rightResult);
        }

        // trace("fin process");

        // 左側と右側の計算結果を統合
        leftResult.reverse();
        var totalResult = leftResult.concat(rightResult);
        // trace('totalResult${totalResult}');

        var resultPoints = new Array<Vec2>();
        var lastPoint:Vec2 = null;
        var size = totalResult.length;
        for(index in 0...size)
        {
            var e1 = totalResult[index];
            var e2 = totalResult[(index + 1) % size];
            // 平行な辺で死ぬところがある
            var point = Collision.getSegmentsIntersectionPoint(e1, e2);
            switch(point)
            {
                case Some(p):
                    if(lastPoint == null || (lastPoint - p).lengthSq() > Settings.epsilon)
                    {
                        resultPoints.push(p);
                        lastPoint = p;
                    }
                case None:
            }
        }

        // 最初と最後がダブるのは防ぎきれないのでここで消す
        if(resultPoints.length != 0 && (resultPoints[0] - lastPoint).lengthSq() <= Settings.epsilon)
        {
            resultPoints.pop();
        }

        // trace('resultPoints: ${resultPoints}');
        return if(resultPoints.length >= 3) Some(new ConvexHull2(resultPoints)) else None;
    }

    // 初回のイベント処理
    // 続けるべきかを返す
    private static function firstPass(status:Status, leftResult:Array<Segment2>, rightResult:Array<Segment2>):MustContinue
    {
        var top1 = status.lefts1[0].vertex1;
        var top2 = status.lefts2[0].vertex1;

        // 2つの凸多角形の低い方の最上点を走査線の初期位置とする
        var sweepY = Math.max(top1.y, top2.y);
        // trace('sweepY: ${sweepY}');

        // 走査線作成
        var sweepLine = Line2.fromPoints(0, sweepY, 1, sweepY);

        // 最初に走査線と交わるような辺のindexをstatusに設定
        var left1 = findInitialEdgeIndex(status.lefts1, sweepLine);
        var right1 = findInitialEdgeIndex(status.rights1, sweepLine);
        var left2 = findInitialEdgeIndex(status.lefts2, sweepLine);
        var right2 = findInitialEdgeIndex(status.rights2, sweepLine);

        // trace('l1: ${left1}, l2: ${left2}, r1: ${right1}, r2: ${right2}');


        switch([left1, left2, right1, right2])
        {
            case [Some(left1), Some(left2), Some(right1), Some(right2)]:
                status.left1 = left1;
                status.right1 = right1;
                status.left2 = left2;
                status.right2 = right2;
            default:
                return No;
        }

        // trace('top1: ${top1}, top2: ${top2}');

        // 初回のイベント処理
        if(top1.y > top2.y)
        {
            if(top1.x > top2.x)
            {
                process(status, EdgePosition.Left1, sweepLine, leftResult, rightResult);
                process(status, EdgePosition.Right1, sweepLine, leftResult, rightResult);
            }
            else
            {
                process(status, EdgePosition.Right1, sweepLine, leftResult, rightResult);
                process(status, EdgePosition.Left1, sweepLine, leftResult, rightResult);
            }
        }
        else
        {
            if(top1.x > top2.x)
            {
                process(status, EdgePosition.Right2, sweepLine, leftResult, rightResult);
                process(status, EdgePosition.Left2, sweepLine, leftResult, rightResult);
            }
            else
            {
                process(status, EdgePosition.Left2, sweepLine, leftResult, rightResult);
                process(status, EdgePosition.Right2, sweepLine, leftResult, rightResult);
            }
        }
        return Yes;
    }

    // 2回目以降のイベント処理
    private static function secondPass(status:Status, leftResult:Array<Segment2>, rightResult:Array<Segment2>):MustContinue
    {
        // 次に処理すべき辺の選択
        var edgePosition = switch(pickNextEdgePosition(status))
        {
            case None:
                return No;
            case Some(edgePosition):
                edgePosition;
        }

        // 選択された辺の始点を走査線の次の位置とする
        var next = switch(edgePosition)
        {
            case Left1:
                status.left1++;
                status.lefts1[status.left1];
            case Right1:
                status.right1++;
                status.rights1[status.right1];
            case Left2:
                status.left2++;
                status.lefts2[status.left2];
            case Right2:
                status.right2++;
                status.rights2[status.right2];
        }

        var nextSweepY = next.vertex1.y;

        // どちらかの最下点を下回ったら終了
        var bot1 = status.lefts1[status.lefts1.length - 1].vertex2;
        var bot2 = status.lefts2[status.lefts2.length - 1].vertex2;
        var bottom = Math.min(bot1.y, bot2.y);

        if(bottom < nextSweepY) return No;

        // trace('nextSweepY: ${nextSweepY}');
        var sweepLine = Line2.fromPoints(0, nextSweepY, 1, nextSweepY);
        
        // イベント処理
        process(status, edgePosition, sweepLine, leftResult, rightResult);
        return Yes;
    }

    private static function process(status:Status, pos:EdgePosition, sweepLine:Line2, leftResult:Array<Segment2>, rightResult:Array<Segment2>):Void
    {
        // これだったら最初からsegmentのリストにしとけばよかったのでは
        var left1 = status.lefts1[status.left1];
        var right1 = status.rights1[status.right1];
        var left2 = status.lefts2[status.left2];
        var right2 = status.rights2[status.right2];

        switch(pos)
        {
            case Left1:
                processLeft(left1, left2, right2, sweepLine, leftResult, rightResult);
            case Right1:
                processRight(right1, left2, right2, sweepLine, leftResult, rightResult);
            case Left2:
                processLeft(left2, left1, right1, sweepLine, leftResult, rightResult);
            case Right2:
                processRight(right2, left1, right1, sweepLine, leftResult, rightResult);
        }
    }

    private static function processLeft(left1:Segment2, left2:Segment2, right2:Segment2,
            sweepLine:Line2, leftResult:Array<Segment2>, rightResult:Array<Segment2>):Void
    {
        var l1 = Collision.getLineAndSegmentIntersectionPoint(sweepLine, left1).getOrElse(left1.vertex1).x;
        var l2 = Collision.getLineAndSegmentIntersectionPoint(sweepLine, left2).getOrElse(left2.vertex1).x;
        var r2 = Collision.getLineAndSegmentIntersectionPoint(sweepLine, right2).getOrElse(right2.vertex1).x;


        // left1がleft2とright2の内部から始まる場合
        if(l2 < l1 && l1 < r2)
        {
            leftResult.push(left1);
        }
        // trace('porcessLeft');
        // trace('\nleftResult1: ${leftResult}');
        // trace('\nrightResult: ${rightResult}');

        // left1がright2と交わり、right2よりも右から始まる場合
        if(Collision.collideSegments(left1, right2) && l1 >= r2)
        {
            /* left1, right2はともに交差凸多角形の一部であり
               必ず上端となるため結果の先頭位置に追加 */
            leftResult.insert(0, left1);
            rightResult.insert(0, right2);
        }
        // trace('\nleftResult2: ${leftResult}');
        // trace('\nrightResult: ${rightResult}');

        // left1がleft2と交わる場合
        if(Collision.collideSegments(left1, left2))
        {
            leftResult.push(if(l1 > l2) left2 else left1);
        }
        // trace('\nleftResult3: ${leftResult}');
        // trace('\nrightResult: ${rightResult}');
    }

    private static function processRight(right1:Segment2, left2:Segment2, right2:Segment2,
            sweepLine:Line2, leftResult:Array<Segment2>, rightResult:Array<Segment2>):Void
    {
        var r1 = Collision.getLineAndSegmentIntersectionPoint(sweepLine, right1).getOrElse(right1.vertex1).x;
        var l2 = Collision.getLineAndSegmentIntersectionPoint(sweepLine, left2).getOrElse(left2.vertex1).x;
        var r2 = Collision.getLineAndSegmentIntersectionPoint(sweepLine, right2).getOrElse(right2.vertex1).x;


        // right1がleft2とright2の内部から始まる場合
        if(l2 < r1  && r1 < r2)
        {
            rightResult.push(right1);
        }
        // trace('porcessRight');
        // trace('\nleftResult1: ${leftResult}');
        // trace('\nrightResult: ${rightResult}');

        // right1がleft2と交わり、かつleft2より左から始まる場合
        if(Collision.collideSegments(right1, left2) && r1 <= l2)
        {
            /* right1, left2は共に交差凸多角形の一部であり
               必ず上端となるため結果の先頭位置に追加 */
            rightResult.insert(0, right1);
            leftResult.insert(0, left2);
        }
        // trace('\nleftResult2: ${leftResult}');
        // trace('\nrightResult: ${rightResult}');

        // right1がright2と交わる場合
        if(Collision.collideSegments(right1, right2))
        {
            rightResult.push(if(r1 < r2) right2 else right1);
        }
        // trace('\nleftResult3: ${leftResult}');
        // trace('\nrightResult: ${rightResult}');
    }

    private static function createSegmentsArray(conv:ConvexHull2, side:Side, det:Vec2):Array<Segment2>
    {
        var minY = Math.POSITIVE_INFINITY;
        var maxY = Math.NEGATIVE_INFINITY;
        var minYIndex = -1;
        var maxYIndex = -1;
        var size = conv.vertices.length;
        
        // 凸多角形の最上点と最下点の位置を指定
        for(index in 0...size)
        {
            var v = conv.vertices[index];
            var y = v.y + det.y;
            if(y < minY)
            {
                minY = y;
                minYIndex = index;
            }
            if(y > maxY)
            {
                maxY = y;
                maxYIndex = index;
            }
        }
        
        var segments = new Array<Segment2>();
        // 反時計回りでなければいけない
        var ccw = Vec2.ccw(conv.vertices[0], conv.vertices[1], conv.vertices[2]);
        Settings.assert(ccw > 0);
        var forward = !Type.enumEq(side, Side.Left);
        var index = minYIndex;
        var nextIndex = 0;
        // 最上点の位置から開始し、最下点に到達するまで続ける
        while(index != maxYIndex)
        {
            nextIndex = (if(forward) index + 1 else index - 1 + size) % size;

            // 両端はちゃんとx座標が合うようにする
            var det1 = if(index == minYIndex) new Vec2(0, det.y) else det;
            var det2 = if(nextIndex == maxYIndex) new Vec2(0, det.y) else det;
            segments.push(new Segment2(conv.vertices[index] + det1, conv.vertices[nextIndex] + det2));
            // indexの更新
            index = nextIndex;
        }
        return segments;
    }

    // ステータスの中から終点のy座標が最も上にある辺を探す
    private static function pickNextEdgePosition(status:Status):Option<EdgePosition>
    {
        var edgePosition = chooseEdgeWithUpperEndY(status, Some(EdgePosition.Left1), Some(EdgePosition.Right1));
        edgePosition = chooseEdgeWithUpperEndY(status, edgePosition, Some(EdgePosition.Left2));
        edgePosition = chooseEdgeWithUpperEndY(status, edgePosition, Some(EdgePosition.Right2));
        return edgePosition;
    }

    private static function chooseEdgeWithUpperEndY(status, pos1:Option<EdgePosition>, pos2:Option<EdgePosition>):Option<EdgePosition>
    {
        var hasNext1 = false;
        var hasNext2 = false;
        var y1 = switch(pos1)
        {
            case Some(pos):
                var edge = getEdgeFromEdgePosition(status, pos);
                hasNext1 = edge.index + 1 < edge.segments.length;
                edge.segments[edge.index].vertex2.y;
            case None:
                Math.POSITIVE_INFINITY;
        }

        var y2 = switch(pos2)
        {
            case Some(pos):
                var edge = getEdgeFromEdgePosition(status, pos);
                hasNext2 = edge.index + 1 < edge.segments.length;
                edge.segments[edge.index].vertex2.y;
            case None:
                Math.POSITIVE_INFINITY;
        }

        return if(y1 == y2)
        {
            // どっちか辺は存在しているか
            if(pos1.isSome())
            {
                // 次のEdgeがある方を返す
                if(hasNext1)
                {
                    pos1;
                }
                else if(hasNext2)
                {
                    pos2;
                }
                else
                {
                    // どちらも次がない
                    None;
                }
            }
            else
            {
                // どっちもPOSITIVE_INFINITY
                None;
            }
        }
        else if(y1 < y2)
        {
            if(hasNext1) pos1 else None;
        }
        else
        {
            if(hasNext2) pos2 else None;
        }
    }

    private inline static function getEdgeFromEdgePosition(status:Status, pos:EdgePosition):{index:Int, segments:Array<Segment2>}
    {
        return switch(pos)
        {
            case Left1:
                {
                    index:status.left1,
                    segments:status.lefts1
                }
            case Right1:
                {
                    index:status.right1,
                    segments:status.rights1
                }
            case Left2:
                {
                    index:status.left2,
                    segments:status.lefts2
                }
            case Right2:
                {
                    index:status.right2,
                    segments:status.rights2
                }
        }
    }

    private static function findInitialEdgeIndex(segments:Array<Segment2>, sweepLine:Line2):Option<Int>
    {
        for(index in 0...segments.length)
        {
            if(Collision.collideLineAndSegment(sweepLine, segments[index]))
            {
                return Some(index);
            }
        }
        return None;
    }

    // 線分同士の交差において、重なっている場合にも頂点を返したい
}

private enum Side
{
    Left;
    Right;
}

private enum EdgePosition
{
    Left1;
    Right1;
    Left2;
    Right2;
}

private typedef Status = {
    var left1:Int;
    var lefts1:Array<Segment2>;
    var right1:Int;
    var rights1:Array<Segment2>;
    var left2:Int;
    var lefts2:Array<Segment2>;
    var right2:Int;
    var rights2:Array<Segment2>;
}

private enum MustContinue
{
    Yes;
    No;
}
