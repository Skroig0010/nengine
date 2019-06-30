package nengine.physics.dynamics.contacts;
import nengine.physics.dynamics.contacts.Contact;
import nengine.components.RigidBody;

class ContactEdge
{
    public var other:RigidBody = null;
    public var contact:Contact = null;
    public var prev:ContactEdge = null;
    public var next:ContactEdge = null;

    public function new(){};
}
