package nengine.math;

class Transform2Data
{
    public var position:Vec2;
    public var rotation:Rot2;

    public function new(position:Vec2, rotation:Rot2)
    {
        this.position = position;
        this.rotation = rotation;
    }
}

