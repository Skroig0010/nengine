package nengine.physics.dynamics;
import nengine.components.Collider;
import nengine.math.*;
import nengine.physics.collision.BroadPhase;
import nengine.physics.collision.shapes.Shape;
import nengine.physics.dynamics.contacts.Contact;

class ContactManager
{
    // 各Colliderがそれぞれレイヤー名を持つようにする
    // ↓ Intでビットマスク作ったほうが良さそう
    // public var layerCollisionSetting:Map<String, Map<String, Bool>>();

    private var contacts:Contact;

    private var broadPhase:BroadPhase;

    public function new (area:AABB2, defaultColliderSize:AABB2)
    {
        broadPhase = new BroadPhase(area, defaultColliderSize);
    }

    public function addShapes(shapes:Array<Shape>, collider:Collider):Void
    {
        broadPhase.addShapes(shapes, collider);
    }

    public function removeShapes(shapes:Array<Shape>, collider:Collider):Void
    {
        broadPhase.removeShapes(shapes, collider);
    }

    public function addColliderToBroadPhase(collider:Collider):Void
    {
        broadPhase.addColliderToTree(collider);
    }

    public function removeColliderFromBroadPhase(collider:Collider):Void
    {
        broadPhase.removeColliderFromTree(collider);
    }

    public function collide():Void
    {
        var contact = contacts;
        while(contact != null)
        {
            var shapeA = contact.shapeA;
            var shapeB = contact.shapeB;
            var colliderA = contact.colliderA;
            var colliderB = contact.colliderB;

            // TODO:動かない者同士なら当たらない
            // TODO:ここにフィルタ実装

            // AABB衝突判定

            // 

            contact = contact.next;
        }
    }

    public function setColliderMoved(collider:Collider):Void
    {
        broadPhase.moveCollider(collider);
    }

    public function findNewContacts():Void
    {
        broadPhase.updatePairs(addPair);
    }
    private function addPair(colliderA:Collider, shapeA:Shape, colliderB:Collider, shapeB:Shape):Void
    {
        var edge = colliderB.contactEdges;
        while(edge != null)
        {
            if(edge.other == colliderA)
            {
                var shapeA2 = edge.contact.shapeA;
                var shapeB2 = edge.contact.shapeB;
                if(shapeA == shapeA2 && shapeB == shapeB2) return;
                if(shapeA == shapeB2 && shapeB == shapeA2) return;
            }
            edge = edge.next;
        }

        // TODO:フィルタ実装

        var contact = Contact.create(colliderA, shapeA, colliderB, shapeB);
        contact.prev = null;
        contact.next = contacts;
        if(contacts != null)
        {
            contacts.prev = contact;
        }
        contacts = contact;

        var nodeA = contact.nodeA;
        nodeA.contact = contact;
        nodeA.other = colliderB;

        nodeA.prev = null;
        nodeA.next = colliderA.contactEdges;
        if(colliderA.contactEdges != null)
        {
            colliderA.contactEdges.prev = nodeA;
        }
        colliderA.contactEdges = nodeA;

        var nodeB = contact.nodeB;
        nodeB.contact = contact;
        nodeB.other = colliderA;

        nodeB.prev = null;
        nodeB.next = colliderB.contactEdges;
        if(colliderB.contactEdges != null)
        {
            colliderB.contactEdges.prev = nodeB;
        }
        colliderB.contactEdges = nodeB;
    }
}
