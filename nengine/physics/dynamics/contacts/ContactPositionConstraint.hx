package nengine.physics.dynamics.contacts;
import nengine.math.*;
import nengine.physics.collision.Manifold;

class ContactPositionConstraint
{
    public var localPoints = new Array<Vec2>();
    public var localNormal:Vec2;
    public var localPoint:Vec2;
    public var indexA:Int;
    public var indexB:Int;
    public var invMassA:Float;
    public var invMassB:Float;
    public var localCenterA:Vec2;
    public var localCenterB:Vec2;
    public var invInertiaA:Float;
    public var invInertiaB:Float;
    public var manifold:Manifold;
    public var radiusA:Float;
    public var radiusB:Float;

    public function new(){}
}

