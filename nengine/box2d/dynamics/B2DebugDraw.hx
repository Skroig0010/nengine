package nengine.box2d.dynamics;
import js.html.CanvasRenderingContext2D;

@:native("Box2D.Dynamics.b2DebugDraw")
extern class B2DebugDraw
{
    public function new():Void;
    public function SetFlags(flags:Int):Void;
    public function SetSprite(sprite:CanvasRenderingContext2D):Void;
    public function GetSprite():CanvasRenderingContext2D;
    public function SetDrawScale(drawScale:Float):Void;
    public function SetLineThickness(lineThickness:Float):Void;
    public function SetFillAlpha(alpha:Float):Void;
}
