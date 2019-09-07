package nengine.physics.collision;
import nengine.math.Vec2;

class RayCastOutput
{
    public var normal:Vec2;
    public var fraction:Float;

    public function new( normal:Vec2, fraction:Float)
    {
        this.normal = normal;
        this.fraction = fraction;
    }
}
