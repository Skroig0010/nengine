package nengine.box2d.dynamics;
import nengine.box2d.collision.shapes.B2Shape;

@:native("Box2D.Dynamics.b2Body")
extern class B2Body
{
    public static var b2_staticBody(default, never):Int;
    public static var b2_kinematicBody(default, never):Int;
    public static var b2_dynamicBody(default, never):Int;
    public function new():Void;
    // public function connectEdges(s1:B2EdgeShape, s2:B2EdgeShape, ?angle:Float):Float;
    public function CreateFixture(def:B2FixtureDef):B2Fixture;
    public function CreateFixture2(shape:B2Shape, ?density:Float):B2Fixture;
    public function DestroyFixture(fixture:B2Fixture):Void;
    // public function SetPositionAndAngle(position:, angle:Float):Void;
}
