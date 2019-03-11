package nengine.components.shapes;
import nengine.math.*;

class PolygonShape implements Shape
{

    public var vertices = new Array<Vec2>();
    public var normals = new Array<Vec2>();

    public function new(vertices:Array<Vec2>, normals:Array<Vec2>)
    {
        this.vertices = vertices;
        this.normals = normals;
    }

    public static function makeBoxTransformed(transform:Transform2, width:Float, height:Float):PolygonShape
    {
        var vertices = [new Vec2(-width/2, -height/2),
                new Vec2(width/2, -height/2),
                new Vec2(-width/2, height/2),
                new Vec2(width/2, height/2)].map((vertex)-> return transform * vertex);
        var normals = [new Vec2(0.0, -1.0),
                new Vec2(1.0, 0.0),
                new Vec2(0.0, 1.0),
                new Vec2(-1.0, 0.0)].map((vertex) -> return transform * vertex);
        var polygon = new PolygonShape(vertices, normals);
        return polygon;
    }

    public static function makeConvexHull(vertices:Array<Vec2>):PolygonShape
    {
        var separated = getSeparatedPoints(vertices);
        var vertices = getConvexHull(separated);
        var normals = computeNormal(vertices);
        return new PolygonShape(vertices, normals);
    }

    public function computeAABB(transform:Transform2):AABB2
    {
        var upper = transform * vertices[0];
        var lower = upper;

        for(index in 1...vertices.length)
        {
            var v = transform * vertices[index];
            upper = Vec2.min(v, upper);
            lower = Vec2.min(v, lower);
        }
        return new AABB2(upper, lower);
    }

    public function clone():PolygonShape
    {
        var vertices = this.vertices.copy();
        var normals = this.normals.copy();
        return new PolygonShape(vertices, normals);
    }

    private static function getSeparatedPoints(vertices:Array<Vec2>):Array<Vec2>
    {
        var ps = new Array<Vec2>();
        for(vertex in vertices)
        {
            var unique = true;
            for(pv in ps)
            {
                if(Vec2.distanceSq(vertex, pv) < (0.5 * 0.005) * (0.5 * 0.005))
                {
                    unique = false;
                    break;
                }
            }

            if(unique)
            {
                ps.push(vertex);
            }
        }

        if(ps.length < 3)
        {
            throw "Cannot generate polygon:Few valid vertices";
        }
        return ps;
    }

    // 凸包の作成
    private static function getConvexHull(vertices:Array<Vec2>):Array<Vec2>
    {
        // 最右点の検索
        var rightPoint = vertices[0];
        for(index in 1...vertices.length)
        {
            if(vertices[index].x > rightPoint.x || (vertices[index].x == rightPoint.x && vertices[index].y < rightPoint.y))
            {
                rightPoint = vertices[index];
            }
        }
        var hullPoint = rightPoint;

        var hull = new Array<Vec2>();
        do
        {
            hull.push(hullPoint);
            var checkPoint = vertices[0];

            for(index in 1...vertices.length)
            {
                // 今の点と同じ点なら次へ
                if(checkPoint == hullPoint)
                {
                    checkPoint = vertices[index];
                    continue;
                }

                var r = checkPoint - hull[hull.length-1];
                var v = vertices[index] - hull[hull.length-1];
                var c = r.cross(v);

                // checkPointよりも角度がゆるいものがあったらそちらに変更
                if(c < 0.0)
                {
                    checkPoint = vertices[index];
                }

                // 現在の点が被ってるなら変更
                if(c == 0 && v.lengthSq() > r.lengthSq())
                {
                    checkPoint = vertices[index];
                }
            }

            hullPoint = checkPoint;
        }
        while(hullPoint == rightPoint);

        if(hull.length < 3)
        {
            throw "Cannot generate polygon:Few valid vertices";
        }

        return hull;
    }

    private static function computeNormal(vertices:Array<Vec2>):Array<Vec2>
    {
        var normals = new Array<Vec2>();
        for (index in 0...vertices.length)
        {
            var index1 = index;
            var index2 = if(index + 1 < vertices.length) index + 1 else 0;
            var edge = vertices[index2] - vertices[index1];
            if(edge.lengthSq() < 0.000000001/*数は適当.FLT_EPSILON的なものがあったらそれを使う*/)
            {
                throw "Edge length is too short";
            }
            edge = Vec2.crossVF(edge, 1.0);
            normals.push(edge.normalize());
        };
        return normals;
    }

}
