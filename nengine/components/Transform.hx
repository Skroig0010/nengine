package nengine.components;
import ecs.Component;
import nengine.math.*;

// transform component for vec2
class Transform implements Component
{
    public static inline var componentName = "Transform";
    public var name(default, never) = componentName;
    public var local(default, set):Transform2;
    @:isVar public var global(get, set):Transform2;
    public var parent:Transform = null;
    public var positionUpdated = false;

    public function new(?position:Vec2, ?rotation:Rot2)
    {
        local = new Transform2(position, rotation);
    }

    private function get_global():Transform2
    {
        return if(parent != null)
        {
            var global = parent.global;
            new Transform2(
                    global * local.position,
                    local.rotation * global.rotation
                    );
        }
        else
        {
            local;
        }
    }

    private function set_local(transform:Transform2):Transform2
    {
        positionUpdated = true;
        return this.local = transform;
    }

    private function set_global(transform:Transform2):Transform2
    {
        positionUpdated = true;
        return local = if(parent != null)
        {
            var global = parent.global;
            new Transform2(
                    Transform2.mulXT(global, transform.position),
                    Rot2.mulT(transform.rotation, global.rotation)
                    );
        }
        else
        {
            transform;
        }
    }
}
