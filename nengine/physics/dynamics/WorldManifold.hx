package nengine.physics.dynamics;
import nengine.math.*;
import nengine.physics.collision.Manifold;

class WorldManifold
{
    public var normal:Vec2;
    public var points = new Array<Vec2>();
    public var separations = new Array<Float>();

    public function new (manifold:Manifold, transformA:Transform2, radiusA:Float, transformB:Transform2, radiusB:Float)
    {
        switch(manifold)
        {
            case None:
                throw "Manifold shouldn't be None";
            case Circles(points, localNormal, localPoint):
                normal = new Vec2(1.0, 0.0);
                var pointA = transformA * localPoint;
                var pointB = transformB * points[0].localPoint;

                if(Vec2.distanceSq(pointA, pointB) > 0.001)
                {
                    normal = pointB - pointA;
                    normal = normal.normalize();
                }
                var cA = pointA + radiusA * normal;
                var cB = pointB - radiusB * normal;
                this.points.push(0.5 * (cA + cB));
                this.separations.push((cB - cA).dot(normal));
            case FaceA(points, localNormal, localPoint):
                normal = transformA.rotation * localNormal;
                var planePoint = transformA * localPoint;

                for(point in points)
                {
                    var clipPoint = transformB * point.localPoint;
                    var cA = clipPoint + (radiusA - (clipPoint - planePoint).dot(normal)) * normal;
                    var cB = clipPoint - radiusB * normal;
                    this.points.push(0.5 * (cA + cB));
                    this.separations.push((cB - cA).dot(normal));
                }
            case FaceB(points, localNormal, localPoint):
                normal = transformB.rotation * localNormal;
                var planePoint = transformB * localPoint;

                for(point in points)
                {
                    var clipPoint = transformA * point.localPoint;
                    var cB = clipPoint + (radiusB - (clipPoint - planePoint).dot(normal)) * normal;
                    var cA = clipPoint - radiusA * normal;
                    this.points.push(0.5 * (cA + cB));
                    this.separations.push((cA - cB).dot(normal));
                }
                normal = -normal;
        }
    }
}
