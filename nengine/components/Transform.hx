package nengine.components;
import ecs.Component;
import nengine.math.*;

// transform component for vec2
class Transform implements Component
{
    public var name(default, never) = "Transform";
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
            new Transform2(
                parent.global.position + parent.global.rotation * local.position,
                local.rotation * parent.global.rotation
                );
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
            new Transform2(
                Vec2.rotVecT(parent.global.rotation, transform.position - parent.global.position),
                Rot2.mulT(transform.rotation, parent.global.rotation)
                );
        }
        else
        {
            transform;
        }
    }
}
