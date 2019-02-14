package nengine.components;
import ecs.Entity;
import ecs.Component;
import ecs.Signal;
import nengine.components.Transform;
import nengine.math.*;
import nengine.systems.PhysicsSystem;

// Box2Dのbody
class RigidBody implements Component
{
    // Component Data
    public var name(default, never) = "RigidBody";

    public function new()
    {
    }
}
