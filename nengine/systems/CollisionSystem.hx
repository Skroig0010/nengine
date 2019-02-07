package nengine.systems;
import ecs.Component;
import ecs.Entity;
import ecs.System;
import ecs.World;
import nengine.components.Collider;
using Lambda;

class CollisionSystem implements System
{
    /*
    ControllerはCollider.onCollideからデータを受け取り判断をする

    マップチップによる衝突判定の高速化
    AABB木や四分木などによる高速化
    この辺空間分割を自由に選べる感じの拡張性も持たせたい
    レイヤー名はStringで管理しているがIntにしたみもある
    */

    public var world:World;
    private var layerPair = new Array<{layerA:String, layerB:String}>();
    private var entityLayers = new Map<String, Array<Entity>>();

    // ここ追加する場合はonComponentAdded等修正する必要が出てくるので注意
    private var componentNames(null, never) = ["Collider"];

    public function new(world:World, layerPair:Array<{layerA:String, layerB:String}>)
    {
        world.addSystem(this);
        this.world = world;
        this.layerPair = layerPair;
        world.entityAdded(componentNames).add(onEntityAdded);
        world.entityRemoved(componentNames).add(onEntityRemoved);
        // entityLayersの作成
        world.getEntities(componentNames).iter(onEntityAdded);
    }

    public function update(dt:Float):Void
    {
        // TODO:entityLayersを木にしたときのアップデート?
        layerPair.iter((layers)->
                {
                    // TODO:以下のentityLayersを四分木から取ってくるような構造にする
                    // entityLayersを木にすればいい？
                    var entityLayersA = entityLayers.get(layers.layerA);
                    var entityLayersB = entityLayers.get(layers.layerB);
                    // 重複しているなら上三角のみ判定を行う
                    for(indexA in 0...entityLayersA.length)
                    {
                        for(indexB in 0...entityLayersB.length)
                        {
                            if(layers.layerA == layers.layerB && indexA <= indexB) break;
                            hitCheck(entityLayersA[indexA], entityLayersB[indexB]);
                        }
                    }
                });
    }

    private function hitCheck(entityA:Entity, entityB:Entity):Void
    {
        var colliderA = cast (entityA.getComponent("Collider"), Collider);
        var colliderB = cast (entityB.getComponent("Collider"), Collider);
        if(colliderA.shape.onBroadPhase(colliderB.shape) &&
                colliderA.shape.on(colliderB.shape))
        {
            colliderA.onCollide(entityB);
            colliderB.onCollide(entityA);
        }
    }

    private function setEntityLayers(entity:Entity, collider:Collider):Void
    {
        entity.onComponentAdded.add(onComponentAdded);
        entity.onComponentRemoved.add(onComponentRemoved);

        if(!entityLayers.exists(collider.layer))
        {
            entityLayers.set(collider.layer, new Array<Entity>());
        }
        entityLayers.get(collider.layer).push(entity);
        collider.onLayerChanged.add(onLayerChanged);
    }

    private function removeEntityLayers(entity:Entity, collider:Collider):Void
    {
        entity.onComponentAdded.remove(onComponentAdded);
        entity.onComponentRemoved.remove(onComponentRemoved);

        entityLayers.get(collider.layer).remove(entity);
        collider.onLayerChanged.remove(onLayerChanged);
    }

    private function onEntityAdded(entity:Entity):Void
    {
        var collider = cast (entity.getComponent("Collider"));
        setEntityLayers(entity, collider);
    }

    private function onEntityRemoved(entity:Entity):Void
    {
        var collider = cast (entity.getComponent("Collider"));
        removeEntityLayers(entity, collider);
    }

    private function onComponentAdded(msg:{entity:Entity, componentName:String, component:Component}):Void
    {
        if(!componentNames.has(msg.componentName)) return;

        setEntityLayers(msg.entity, cast (msg.component, Collider));
    }

    private function onComponentRemoved(msg:{entity:Entity, componentName:String, component:Component}):Void
    {
        if(!componentNames.has(msg.componentName)) return;

        removeEntityLayers(msg.entity, cast (msg.component, Collider));
    }

    private function onLayerChanged(msg:{entity:Entity, collider:Collider}):Void
    {
        removeEntityLayers(msg.entity, msg.collider);
        setEntityLayers(msg.entity, msg.collider);
    }

}
