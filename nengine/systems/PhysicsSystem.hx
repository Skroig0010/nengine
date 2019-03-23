package nengine.systems;
import ecs.System;
import ecs.World;
import ecs.Entity;
import nengine.components.Transform;
import nengine.components.Collider;
import nengine.physics.collision.shapes.Shape;
import nengine.physics.collision.QuadTree;
import nengine.physics.collision.Collision;
import nengine.math.*;
import nengine.physics.dynamics.contacts.Contact;
import nengine.physics.dynamics.ContactManager;

using Lambda;

class PhysicsSystem implements System
{
    public var world:World;
    private var components(default, never) = [Transform.componentName, Collider.componentName];
    private var contacts:Contact;
    private var contactManager:ContactManager;

    public function new(area:AABB2, defaultColliderSize:AABB2)
    {
        contactManager = new ContactManager(area, defaultColliderSize);
        world.getEntities(components).iter((entity)->{
            var collider = cast(entity.getComponent(Collider.componentName), Collider);
            contactManager.addColliderToBroadPhase(collider);
        });
        world.entityAdded(components).add(onEntityAdded);
        world.entityRemoved(components).add(onEntityRemoved);
    }

    public function addShapes(shapes:Array<Shape>, collider:Collider):Void
    {
        contactManager.addShapes(shapes, collider);
    }

    public function removeShapes(shapes:Array<Shape>, collider:Collider):Void
    {
        contactManager.removeShapes(shapes, collider);
    }

    private function onEntityAdded(entity):Void
    {
            var collider = cast(entity.getComponent(Collider.componentName), Collider);
            contactManager.addColliderToBroadPhase(collider);
    }

    private function onEntityRemoved(entity):Void
    {
            var collider = cast(entity.getComponent(Collider.componentName), Collider);
            contactManager.removeColliderFromBroadPhase(collider);
    }

    public function update(dt:Float)
    {
        var entities = world.getEntities(components);
        // 移動したEntityがあれば四分木を更新しContactリスト更新
        var movedEntities = entities.filter((entity)->{
            var transform = cast(entity.getComponent(Transform.componentName), Transform);
            return transform.positionUpdated;
        });
        movedEntities.map((entity)->{
            var collider = cast(entity.getComponent(Collider.componentName), Collider);
            contactManager.setColliderMoved(collider);
        });

        contactManager.findNewContacts();

        movedEntities.iter((entity)->{
            var transform = cast(entity.getComponent(Transform.componentName), Transform);
            transform.positionUpdated = false;
        });
    }
}
