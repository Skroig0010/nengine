package nengine.physics.dynamics.contacts;
import nengine.math.*;

class ContactVelocityConstraint
{
    public var points = new Array<VelocityConstraintPoint>();
    public var normal:Vec2;
    public var normalMass:Mat22;
    public var k:Mat22;
    public var indexA:Int;
    public var indexB:Int;
    public var invMassA:Float;
    public var invMassB:Float;
    public var invInertiaA:Float;
    public var invInertiaB:Float;
    public var friction:Float;
    public var restitution:Float;
    public var tangentSpeed:Float;
    public var contactIndex:Int;


    public function new(){}
}
