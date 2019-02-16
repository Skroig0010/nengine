package nengine.box2d.dynamics;
import nengine.box2d.common.math.B2Vec2;

@:native("Box2D.Dynamics.b2BodyDef")
extern class B2BodyDef
{
    public function new():Void;
    public var type:Int;
    public var position:B2Vec2;

}
