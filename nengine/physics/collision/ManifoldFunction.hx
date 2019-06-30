package nengine.physics.collision;
import nengine.math.Vec2;

class ManifoldFunction
{
    public static function pointCount(manifold:Manifold):Int
    {
        return switch(manifold)
        {
            case None: 0;
            case Circles(points, _, _)
                | FaceA(points, _, _)
                | FaceB(points, _, _): points.length;
        }
    }

    public static function points(manifold:Manifold):Array<ManifoldPoint>
    {
        return switch(manifold)
        {
            case None: [];
            case Circles(points, _, _)
                | FaceA(points, _, _)
                | FaceB(points, _, _): points;
        }
    }

    public static function localNormal(manifold:Manifold):Vec2
    {
        return switch(manifold)
        {
            case None: new Vec2();
            case Circles(_, localNormal, _)
                | FaceA(_, localNormal, _)
                | FaceB(_, localNormal, _): localNormal;
        }
    }

    public static function localPoint(manifold:Manifold):Vec2
    {
        return switch(manifold)
        {
            case None: new Vec2();
            case Circles(_, _, localPoint)
                | FaceA(_, _, localPoint)
                | FaceB(_, _, localPoint): localPoint;
        }
    }

    public static function mapPoints(manifold:Manifold, func:ManifoldPoint->Void):Void
    {
        switch(manifold)
        {
            case None:
            case Circles(points, _, _)
                | FaceA(points, _, _)
                | FaceB(points, _, _):
                {
                    for(point in points) func(point);
                }
        }
    }

    public static function isSame(pointA:ManifoldPoint, pointB:ManifoldPoint):Bool
    {
        return Type.enumEq(pointA.contactFeature.a, 
        pointB.contactFeature.a) &&
        Type.enumEq(pointA.contactFeature.b,
        pointB.contactFeature.b);
    }
}
