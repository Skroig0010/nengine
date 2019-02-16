package nengine.box2d.common.math;

@:native("Box2D.Common.Math.b2Vec2")
extern class B2Vec2
{
    public function new(x_:Int, y_:Int):Void;
    public function SetZero():Void;
    public function Set(x_:Float, y_:Float):Void;
    public function SetV(v:B2Vec2):Void;
    public function GetNegative():B2Vec2;
    public function NegativeSelf():Void;
}
