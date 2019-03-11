package nengine.physics.collision;
import nengine.math.*;

class Manifold
{
    public var type:ManifoldType;
    public var points:Array<ManifoldPoint>;
    public var localNormal:Vec2;
    public var localPoint:Vec2;

    public function new(type:ManifoldType, points:Array<ManifoldPoint>, localNormal:Vec2, localPoint:Vec2)
    {
        this.type = type;
        this.points = points;
        this.localNormal = localNormal;
        this.localPoint = localPoint;
    }
}
