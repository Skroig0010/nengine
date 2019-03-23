package nengine.physics.collision;

class ManifoldFunction
{
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
