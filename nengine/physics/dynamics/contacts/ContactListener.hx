package nengine.physics.dynamics.contacts;
import nengine.physics.collision.Manifold;

interface ContactListener
{
    public function beginContact(contact:Contact):Void;
    public function endContact(contact:Contact):Void;

    public function preSolve(contact:Contact, oldManifold:Manifold):Void;
    public function postSolve(contact:Contact, impulse:ContactImpulse):Void;
}
