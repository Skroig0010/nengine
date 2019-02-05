package nengine.components;
import ecs.Component;
import nengine.math.Vec2;

typedef Transform2DBase = {
    position:Vec2,
    rotation:Float,
    scale:Vec2
}

// transform component for vec2
class Transform2D implements Component implements Transformable<Transform2DBase>
{
    public var name(default, null) = "Transform2D";
    public var local:Transform2DBase;
    @:isVar public var global(get, set):Transform2DBase;
    public var parent:Transformable<Transform2DBase> = null;

    public function new(?x:Float, ?y:Float, ?rotation:Float, ?scaleX:Float, ?scaleY:Float)
    {
        local = {
            position:new Vec2(
                             if(x != null) x else 0,
                             if(y != null) y else 0),
            rotation:if(rotation != null) rotation else 0,
            scale:new Vec2(
                    if(scaleX != null) scaleX else 1,
                    if(scaleY != null) scaleY else 1)
        };
    }

    private function get_global():Transform2DBase
    {
        return if(parent != null)
        {
            {
                position:local.position + parent.global.position,
                rotation:local.rotation + parent.global.rotation,
                scale:new Vec2(local.scale.x * parent.global.scale.x, local.scale.y * parent.global.scale.y)
            };
        }
        else
        {
            local;
        }
    }

    private function set_global(transform:Transform2DBase):Transform2DBase
    {
        return local = if(parent != null)
        {
            {
                position:transform.position - parent.global.position,
                rotation:transform.rotation - parent.global.rotation,
                scale:new Vec2(
                        if(parent.global.scale.x != 0) transform.scale.x/parent.global.scale.x else 0,
                        if(parent.global.scale.y != 0) transform.scale.y/parent.global.scale.y else 0)
            };
        }
        else
        {
            transform;
        }
    }
}
