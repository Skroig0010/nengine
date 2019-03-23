package nengine.physics.collision;
import nengine.components.Collider;
import nengine.physics.dynamics.contacts.Contact;

class ContactEdge
{
    public var other:Collider = null;
    public var contact:Contact = null;
    public var prev:ContactEdge = null;
    public var next:ContactEdge = null;

    public function new(){};
}
