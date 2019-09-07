package nengine.physics.collision;
import nengine.math.Vec2;

class RayCastInput
{
    public var p1:Vec2;
    public var p2:Vec2;
    public var maxFraction:Float;

    public function new( p1:Vec2, p2:Vec2, maxFraction:Float)
    {
        this.p1 = p1;
        this.p2 = p2;
        this.maxFraction = maxFraction;
    }
}
