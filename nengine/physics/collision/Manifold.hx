package nengine.physics.collision;
import nengine.math.Vec2;

enum Manifold
{
    None;
    Circles(points:Array<ManifoldPoint>, localNormal:Vec2, localPoint:Vec2);
    FaceA(points:Array<ManifoldPoint>, localNormal:Vec2, localPoint:Vec2);
    FaceB(points:Array<ManifoldPoint>, localNormal:Vec2, localPoint:Vec2);
}

