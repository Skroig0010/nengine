package nengine.box2d.dynamics;
import nengine.box2d.common.math.B2Vec2;

@:native("Box2D.Dynamics.b2World")
extern class B2World
{
    public function new(gravity:B2Vec2, doSleep:Bool):Void;
    public function CreateBody(def:B2BodyDef):B2Body;
    public function GetGroundBody():B2Body;
    // public function CreateJoint(def:B2JointDef):B2Joint;
    public function SetDebugDraw(debugDraw:B2DebugDraw):Void;
    public function Step(?dt:Float, velocityIterations:Int, positionIterations:Int):Void;
    public function DrawDebugData():Void;
    public function ClearForces():Void;

}
