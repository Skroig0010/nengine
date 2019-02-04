package nengine.components;
import ecs.Component;
import ecs.Entity;

interface Collidable<T> extends Component extends Transformable<T>
{
    public function on(other:Entity):Bool;
}