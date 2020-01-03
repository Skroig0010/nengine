package nengine.physics.dynamics;
import nengine.math.*;
import nengine.physics.collision.Collision;
import nengine.physics.collision.shapes.Shape;
import nengine.physics.collision.BroadPhase;
import nengine.physics.dynamics.contacts.Contact;
import nengine.physics.dynamics.contacts.ContactListener;

class ContactManager
{
    public var contacts:Contact;

    public var broadPhase:BroadPhase;
    public var contactFilter:Option<ContactFilter> = None;
    public var contactListener:Option<ContactListener> = None;

    public function new (broadPhase:BroadPhase)
    {
        this.broadPhase = broadPhase;
    }

    public function findNewContacts():Void
    {
        broadPhase.updatePairs(addPair);
    }

    public function destroy(contact:Contact):Void
    {
        var shapeA = contact.shapeA;
        var shapeB = contact.shapeB;
        var bodyA = shapeA.body;
        var bodyB = shapeB.body;

        switch(contactListener)
        {
            case Some(listener) if(contact.touchingFlag):
                listener.endContact(contact);
            case Some(_):
            case None:
        }

        if(contact.prev != null)
        {
            contact.prev.next = contact.next;
        }
        
        if(contact.next != null)
        {
            contact.next.prev = contact.prev;
        }

        if(contact == contacts)
        {
            contacts = contact.next;
        }

        // remove from bodyA
        if(contact.nodeA.prev != null)
        {
            contact.nodeA.prev.next = contact.nodeA.next;
        }

        if(contact.nodeA.next != null)
        {
            contact.nodeA.next.prev = contact.nodeA.prev;
        }

        if(contact.nodeA == bodyA.contactEdges)
        {
            bodyA.contactEdges = contact.nodeA.next;
        }

        // remove from bodyB
        if(contact.nodeB.prev != null)
        {
            contact.nodeB.prev.next = contact.nodeB.next;
        }

        if(contact.nodeB.next != null)
        {
            contact.nodeB.next.prev = contact.nodeB.prev;
        }

        if(contact.nodeB == bodyB.contactEdges)
        {
            bodyB.contactEdges = contact.nodeB.next;
        }
    }

    public function collide():Void
    {
        var contact = contacts;

        while(contact != null)
        {
            var shapeA = contact.shapeA;
            var shapeB = contact.shapeB;
            var bodyA = shapeA.body;
            var bodyB = shapeB.body;

            if(contact.filterFlag)
            {
                switch(contactFilter)
                {
                    case Some(filter):
                    if(!filter.shouldCollide(shapeA, shapeB))
                    {
                        var contactNuke = contact;
                        contact = contactNuke.next;
                        destroy(contactNuke);
                        continue;
                    }
                    case None:
                }
            }
            contact.filterFlag = false;

            var overlap = Collision.collideAABBs(shapeA.cell.fatAABB, shapeB.cell.fatAABB);

            if(!overlap)
            {
                var contactNuke = contact;
                contact = contactNuke.next;
                destroy(contactNuke);
                continue;
            }

            contact.update(contactListener);
            contact = contact.next;
        }
    }

    private function addPair(shapeA:Shape, shapeB:Shape):Void
    {
        var bodyA = shapeA.body;
        var bodyB = shapeB.body;

        if(bodyA == bodyB)return;

        var edge = bodyB.contactEdges;
        while(edge != null)
        {
            if(edge.other == bodyA)
            {
                var shapeA2 = edge.contact.shapeA;
                var shapeB2 = edge.contact.shapeB;

                if(shapeA == shapeA2 && shapeB == shapeB2) return;
                if(shapeA == shapeB2 && shapeB == shapeA2) return;
            }
            edge = edge.next;
        }

        switch(contactFilter)
        {
            case Some(filter):
            if(!filter.shouldCollide(shapeA, shapeB)) return;
            case None:
        }

        var contact = Contact.create(shapeA, shapeB);

        // swapし得るので入れ直し
        shapeA = contact.shapeA;
        shapeB = contact.shapeB;

        bodyA = shapeA.body;
        bodyB = shapeB.body;

        contact.prev = null;
        contact.next = contacts;
        if(contacts != null)
        {
            contacts.prev = contact;
        }
        contacts = contact;

        // bodyAに接続
        contact.nodeA.contact = contact;
        contact.nodeA.other = bodyB;

        contact.nodeA.prev = null;
        contact.nodeA.next = bodyA.contactEdges;
        if(bodyA.contactEdges != null)
        {
            bodyA.contactEdges.prev = contact.nodeA;
        }
        bodyA.contactEdges = contact.nodeA;

        // bodyBに接続
        contact.nodeB.contact = contact;
        contact.nodeB.other = bodyA;

        contact.nodeB.prev = null;
        contact.nodeB.next = bodyB.contactEdges;
        if(bodyB.contactEdges != null)
        {
            bodyB.contactEdges.prev = contact.nodeB;
        }
        bodyB.contactEdges = contact.nodeB;

    }
}
