package nengine.physics.dynamics;

class TimeStep
{
    public var dt:Float;
    public var invDt:Float;
    public var dtRatio:Float;
    public var velocityIterations:Int;
    public var positionIterations:Int;
    public var warmStarting:Bool;

    public function new (){}
}
