package nengine.box2d.dynamics;
import nengine.box2d.collision.shapes.B2Shape;

@:native("Box2D.Dynamics.b2FixtureDef")
extern class B2FixtureDef
{
    public var density:Float;
    public var friction:Float;
    public var restitution:Float;
    public var shape:B2Shape;
}
