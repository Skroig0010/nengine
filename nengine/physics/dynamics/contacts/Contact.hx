package nengine.dynamics.contacts;

class Contact
{
    public var manifold(default, null):Manifold;
    public var prev:Contact;
    public var next:Contact;
    public var bodyA:RigidBody;
    public var bodyB:RigidBody;
    public var colliderA:Collider;
    public var colliderB:Collider;
    public var manifold:Manifold;
}
