package nengine.box2d.common.math;

@:native("Box2D.Common.Math.b2Transform")
extern class B2Transform
{
    public function new(pos:B2Vec2, r:B2Mat22):Void;
    public function Initialize(pos:B2Vec2, r:B2Mat22):Void;
    public function SetIdentity():Void;
    public function Set(x:B2Transform):Void;
}
