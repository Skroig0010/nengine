package nengine.components;
import ecs.Entity;
import ecs.Component;
import ecs.Signal;

class Collider implements Component
{
    public var name(default, never) = "Collider";
    public var shape(default, null):Shape;
    public var layer(default, set):String;
    public var onLayerChanged = new Signal<{entity:Entity, collider:Collider}>();
    private var entity:Entity;
    public var isTrigger(default, null):Bool;
    public var onCollide:Entity->Void;

    public function new(shape:Shape, entity:Entity, layer:String, isTrigger:Bool)
    {
        this.shape = shape;
        this.layer = layer;
        this.entity = entity;
        this.isTrigger = isTrigger;
    }

    private function set_layer(layer:String):String
    {
        this.layer = layer;
        onLayerChanged.emit({entity:entity, collider:this});
        return layer;
    }
}
