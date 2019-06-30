package nengine.physics.dynamics.contacts;
import nengine.math.Vec2;

class VelocityConstraintPoint
{
    public var rA:Vec2;
    public var rB:Vec2;
    public var normalImpulse:Float;
    public var tangentImpulse:Float;
    public var normalMass:Float;
    public var tangentMass:Float;
    public var velocityBias:Float;

    public function new(){}
}
