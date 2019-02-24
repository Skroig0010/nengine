package nengine.physics.collision;
import nengine.math.*;

class Manifold
{
    public var points:Array<Vec2>;
    public var localNormal:Vec2;
    public var localPoint:Vec2;
    public var type:ManifoldType;

    public function new(type:ManifoldType, points:Array<Vec2>, localNormal:Vec2, localPoint:Vec2)
    {
        this.points = points;
        this.localNormal = localNormal;
        this.localPoint = localPoint;
        this.type = type;
    }
}
