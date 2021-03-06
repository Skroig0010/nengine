package nengine.physics.collision.shapes;
import nengine.math.*;
import nengine.physics.collision.ShapeCell;
import nengine.components.RigidBody;

class PolygonShape implements Shape
{
    public var type(default, never) = ShapeType.Polygon;
    public var body:RigidBody;
    public var isSensor:Bool;
    public var cell(default, null):ShapeCell;
    public var friction:Float;
    public var restitution:Float;
    public var density:Float;
    public var name:String;
    public var radius:Float = Settings.polygonRadius;
    // 比較用
    public var id(default, null):Int;

    public var vertices = new Array<Vec2>();
    public var normals = new Array<Vec2>();

    function new(vertices:Array<Vec2>, normals:Array<Vec2>, density:Float, friction:Float, restitution:Float, isSensor:Bool, name:String)
    {
        this.vertices = vertices;
        this.normals = normals;
        this.isSensor = isSensor;
        this.density = density;
        this.friction = friction;
        this.restitution = restitution;
        this.name = name;
        cell = new ShapeCell(this);
        id = ShapeIdCounter.getId();
    }

    public static function makeBox(width:Float, height:Float, density:Float = 0.0, friction:Float = 0.2, restitution:Float = 0.0, isSensor:Bool = false, name:String = ""):PolygonShape
    {
        var vertices = [new Vec2(-width/2, -height/2),
                new Vec2(width/2, -height/2),
                new Vec2(width/2, height/2),
                new Vec2(-width/2, height/2)];
        var normals = [new Vec2(0.0, -1.0),
                new Vec2(1.0, 0.0),
                new Vec2(0.0, 1.0),
                new Vec2(-1.0, 0.0)];
        var polygon = new PolygonShape(vertices, normals, density, friction, restitution, isSensor, name);
        return polygon;
    }


    public static function makeBoxTransformed(transform:Transform2, width:Float, height:Float, density:Float = 0.0, friction:Float = 0.2, restitution:Float = 0.0, isSensor:Bool = false, name:String = ""):PolygonShape
    {
        var vertices = [new Vec2(-width/2, -height/2),
                new Vec2(width/2, -height/2),
                new Vec2(width/2, height/2),
                new Vec2(-width/2, height/2)].map((vertex)-> return transform * vertex);
        var normals = [new Vec2(0.0, -1.0),
                new Vec2(1.0, 0.0),
                new Vec2(0.0, 1.0),
                new Vec2(-1.0, 0.0)].map((vertex) -> return transform.rotation * vertex);
        var polygon = new PolygonShape(vertices, normals, density, friction, restitution, isSensor, name);
        return polygon;
    }

    public static function makeConvexHull(vertices:Array<Vec2>, density:Float = 0.0, friction:Float = 0.2, restitution:Float = 0.0, isSensor:Bool = false, name:String = ""):PolygonShape
    {
        var separated = getSeparatedPoints(vertices);
        var vertices = getConvexHull(separated);
        var normals = computeNormal(vertices);
        return new PolygonShape(vertices, normals, density, friction, restitution, isSensor, name);
    }

    public static function makePolygonAlreadyCCWConvexHull(vertices:Array<Vec2>, density:Float = 0.0, friction:Float = 0.2, restitution:Float = 0.0, isSensor:Bool = false, name:String = ""):PolygonShape
    {
        var normals = computeNormal(vertices);
        return new PolygonShape(vertices, normals, density, friction, restitution, isSensor, name);
    }

    public function rayCast(input:RayCastInput, transform:Transform2):Option<RayCastOutput>
    {
        var p1 = Transform2.mulXT(transform, input.p1);
        var p2 = Transform2.mulXT(transform, input.p2);
        var d = p2 - p1;

        var lower = 0.0;
        var upper = input.maxFraction;

        var resultIndex = -1;

        for(index in 0...vertices.length)
        {
            var numerator = normals[index].dot(vertices[index] - p1);
            var denominator = normals[index].dot(d);

            if(denominator == 0.0)
            {
                if(numerator < 0.0) return None;
            }
            else
            {
                if(denominator < 0.0 && numerator < lower * denominator)
                {
                    lower = numerator / denominator;
                    resultIndex = index;
                }
                else if(denominator > 0.0 && numerator < upper * denominator)
                {
                    upper = numerator / denominator;
                }
            }

            if(upper < lower)
            {
                return None;
            }
        }

        Settings.assert(0.0 <= lower && lower <= input.maxFraction);

        if(resultIndex >= 0)
        {
            return Some(new RayCastOutput(transform.rotation * normals[resultIndex], lower));
        }

        return None;
    }

    public function testPoint(transform:Transform2, p:Vec2):Bool
    {
        var pLocal = Transform2.mulXT(transform, p);

        for(index in 0...vertices.length)
        {
            var dot = normals[index].dot(pLocal - vertices[index]);
            if(dot > 0.0) return false;
        }

        return true;
    }

    public function computeAABB(transform:Transform2):AABB2
    {
        var upper = transform * vertices[0];
        var lower = upper;

        for(index in 1...vertices.length)
        {
            var v = transform * vertices[index];
            upper = Vec2.min(v, upper);
            lower = Vec2.max(v, lower);
        }
        return new AABB2(upper, lower);
    }

    public function computeMass():MassData
    {
        Settings.assert(vertices.length >= 3);

        var center = new Vec2(0.0, 0.0);
        var area = 0.0;
        var inertia = 0.0;

        var s = new Vec2(0.0, 0.0);

        for(vertex in vertices)
        {
            s += vertex;
        }
        s *= 1.0 / vertices.length;

        final inv3 = 1.0/3.0;

        for(index in 0...vertices.length)
        {
            // triangle vertices
            var e1 = vertices[index] - s;
            var e2 = if(index + 1 < vertices.length) vertices[index + 1] -s else vertices[0] - s;

            var d = e1.cross(e2);

            var triangleArea = 0.5 * d;
            area += triangleArea;

            // area weighted centroid
            center += triangleArea * inv3 * (e1 + e2);

            var ex1 = e1.x, ey1 = e1.y;
            var ex2 = e2.x, ey2 = e2.y;

            var intx2 = ex1*ex1 + ex2*ex1 + ex2*ex2;
            var inty2 = ey1*ey1 + ey2*ey1 + ey2*ey2;

            inertia += (0.25 * inv3 * d) * (intx2 + inty2);
        }

        var massData = new MassData();

        // total mass
        massData.mass = density * area;

        // center of mass
        Settings.assert(area > 0.001);
        center *= 1.0 / area;
        massData.center = center + s;

        // inertia tensor relative to the local origin (point s)
        massData.inertia = density * inertia;

        // shift to center of mass then to original body origin
        massData.inertia += massData.mass * (massData.center.dot(massData.center) - center.dot(center));

        return massData;
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
        while(hullPoint != rightPoint);

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
            if(edge.lengthSq() < Settings.epsilon)
            {
                throw "Edge length is too short";
            }
            edge = Vec2.crossVF(edge, 1.0);
            normals.push(edge.normalize());
        };
        return normals;
    }

}
