package nengine.components;
import ecs.Component;
import nengine.math.Vec2;

// transform component for vec2
class Transform2 implements Component implements Transformable<Vec2>
{
    public var name(default, null) = "Transform2";
    public var local(default, default):Vec2;
    @:isVar public var global(get, set):Vec2;
    public var parent(default, default):Transformable<Vec2> = null;

    public function new(?position:Vec2, ?x:Float, ?y:Float)
    {
        if(position != null)
        {
            local = position;
        }
        else
        {
            local = new Vec2(
                    if(x != null) x else 0,
                    if(y != null) y else 0);
        }
    }

    private function get_global():Vec2
    {
        return if(parent != null)
        {
            local+parent.global;
        }
        else
        {
            local;
        }
    }

    private function set_global(position:Vec2):Vec2
    {
        return global = if(parent != null)
        {
            local - parent.global;
        }
        else
        {
            position;
        }
    }
}
