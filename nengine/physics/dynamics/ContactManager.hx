package nengine.physics.dynamics;
import nengine.physics.collision.BroadPhase2;

class ContactManager
{
    public var broadPhase(default, null):BroadPhase2;

    public function new(world:PhysicsSystem, )
    {
      this.world = world;
      contactCount = 0;
      contactFilter = b2ContactFilter.b2_defaultFilter;
      contactListener = b2ContactListener.b2_defaultListener;
      contactFactory = new b2ContactFactory(this.m_allocator);
      broadPhase = new BroadPhase();
    }
}
