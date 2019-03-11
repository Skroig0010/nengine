package nengine.physics.collision;
import nengine.math.*;

class ManifoldPoint
{
    public var localPoint:Vec2;
    public var normalImpulse:Float;
    public var tangentImpulse:Float;
    public var contactFeature:ContactFeature;

    public function new(localPoint:Vec2, normalImpulse:Float, tangentImpulse:Float, contactFeature:ContactFeature)
    {
        this.localPoint = localPoint;
        this.normalImpulse = normalImpulse;
        this.tangentImpulse = tangentImpulse;
        this.contactFeature = contactFeature;
    }
}
