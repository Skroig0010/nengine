package nengine.physics.dynamics.contacts;
import nengine.math.*;

class PositionSolverManifold
{
    public var normal:Vec2;
    public var point:Vec2;
    public var separation:Float;

    public function new(pc:ContactPositionConstraint, transformA:Transform2, transformB:Transform2, index:Int)
    {

        switch(pc.manifold)
        {
            case None:
                throw "error in PositionSolverManifold";
            case Circles(_, _, _):
                var pointA = transformA * pc.localPoint;
                var pointB = transformB * pc.localPoints[0];
                normal = pointB - pointA;
                normal.normalize();
                point = 0.5 * (pointA + pointB);
                separation = (pointB - pointA).dot(normal) - pc.radiusA - pc.radiusB;

            case FaceA(points, localNormal, localPoint):
                normal = transformA.rotation * pc.localNormal;
                var planePoint = transformA * pc.localPoint;

                var clipPoint = transformB * pc.localPoints[index];
                separation = (clipPoint - planePoint).dot(normal) - pc.radiusA - pc.radiusB;
                point = clipPoint;

            case FaceB(points, localNormal, localPoint):
                normal = transformB.rotation * pc.localNormal;
                var planePoint = transformB * pc.localPoint;

                var clipPoint = transformA * pc.localPoints[index];
                separation = (clipPoint - planePoint).dot(normal) - pc.radiusA - pc.radiusB;
                point = clipPoint;

                // ensure normal points from A to B
                normal = -normal;
        }
    }
}
