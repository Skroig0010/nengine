package nengine.components;
import ecs.Component;
import nengine.math.*;

// transform component for vec2
class Transform implements Component
{
    public static inline var componentName = "Transform";
    public var name(default, never) = componentName;
    public var local:Transform2;
    @:isVar public var global(get, set):Transform2;
    public var parent:Transform = null;

    public function new(?position:Vec2, ?rotation:Rot2)
    {
        local = new Transform2(position, rotation);
    }

    private function get_global():Transform2
    {
        return if(parent != null)
        {
            parent.global * local;
        }
        else
        {
            local;
        }
    }

    private function set_global(transform:Transform2):Transform2
    {
        return local = if(parent != null)
        {
            Transform2.mulT(parent.global, transform);
        }
        else
        {
            transform;
        }
    }
}
