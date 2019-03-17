package nengine.systems;
import ecs.System;
import ecs.World;
import ecs.Entity;
import nengine.components.Transform;
import nengine.components.Collider;
import nengine.components.shapes.CircleShape;
import nengine.components.shapes.PolygonShape;
import nengine.physics.collision.QuadTree;
import nengine.physics.collision.Collision;
import nengine.physics.collision.ManifoldType;
import nengine.math.*;
import nengine.physics.dynamics.contacts.Contact;

using Lambda;

class PhysicsSystem implements System
{
    public var world:World;
    // 各Colliderがそれぞれレイヤー名を持つようにする
    // ↓ Intでビットマスク作ったほうが良さそう
    // public var layerCollisionSetting:Map<String, Map<String, Bool>>();
    private var quadTree:QuadTree;
    private var components(default, never) = [Transform.componentName, Collider.componentName];
    private var contacts:Contact;

    public function new(world:World, width:Int, height:Int)
    {
        quadTree = new QuadTree(2, new AABB2(new Vec2(0, 0), new Vec2(width, height)));
        quadTree.addEntities(world.getEntities(components));
        world.entityAdded(components).add(quadTree.onEntityAdded);
        world.entityRemoved(components).add(quadTree.onEntityRemoved);
    }

    public function update(dt:Float)
    {
        // ゲーム毎に以下を実装すればいい
        var entities = world.getEntities(components);
        // 移動したEntityがあれば四分木を更新
        var movedEntities = entities.filter((entity)->{
            var transform = cast(entity.getComponent(Transform.componentName), Transform);
            return transform.positionUpdated;
        });
        movedEntities.map(quadTree.updateEntity);

        for(entity in entities)
        {
            quadTree.checkHit(entity, collisionCheck);
        }

        movedEntities.iter((entity)->{
            var transform = cast(entity.getComponent(Transform.componentName), Transform);
            transform.positionUpdated = false;
        });
    }

    private function collisionCheck(entity1:Entity, entity2:Entity):Void
    {
        if(entity1 == entity2) return;
        var transform1 = cast(entity1.getComponent(Transform.componentName), Transform);
        var transform2 = cast(entity2.getComponent(Transform.componentName), Transform);
        var body1 = cast(entity1.getComponent(Collider.componentName), Collider);
        var body2 = cast(entity2.getComponent(Collider.componentName), Collider);
        if(!Collision.collideAABBs(body1.getAABB(transform1.global), body2.getAABB(transform2.global))) return;
        // 衝突検出
        for(shape1 in body1.shapes)
        {
            for(shape2 in body2.shapes)
            {
                var manifold = switch([shape1.type, shape2.type])
                {
                    case [Circle, Circle]:
                        Collision.collideCircles(cast(shape1, CircleShape), transform1.global, cast(shape2, CircleShape), transform2.global);
                    case [Circle, Polygon]:
                        Collision.collidePolygonAndCircle(cast(shape2, PolygonShape), transform2.global, cast(shape1, CircleShape), transform1.global);
                    case [Polygon, Circle]:
                        Collision.collidePolygonAndCircle(cast(shape1, PolygonShape), transform1.global, cast(shape2, CircleShape), transform2.global);
                    case [Polygon, Polygon]:
                        Collision.collidePolygons(cast(shape1, PolygonShape), transform1.global, cast(shape2, PolygonShape), transform2.global);
                }

                if(manifold.type != ManifoldType.None)
                {
                    // 衝突応答
                }
            }
        }
    }

}
