package nengine.components;
import ecs.Component;
import nengine.math.*;

class RigidBody implements Component
{
    public static inline var componentName = "RigidBody";
    public var name(default, never) = componentName;
    @:isVar public var invMass(default, set):Float;
    @:isVar public var mass(default, set):Float; 
    public var inertia(default, set):Float;
    public var invInertia(default, set):Float;
    private function set_invMass(invMass:Float):Float
    {
        mass = if(invMass != 0) 1 / invMass else Math.POSITIVE_INFINITY;
        return this.invMass = invMass;
    }

    private function set_mass(mass:Float):Float
    {
        invMass = if(mass != 0) 1 / mass else Math.POSITIVE_INFINITY;
        return this.mass = mass;
    }

    private function set_invInertia(invInertia:Float):Float
    {
        inertia = if(invInertia != 0) 1 / invInertia else Math.POSITIVE_INFINITY;
        return this.invInertia = invInertia;
    }

    private function set_inertia(inertia:Float):Float
    {
        invInertia = if(inertia != 0) 1 / inertia else Math.POSITIVE_INFINITY;
        return this.inertia = inertia;
    }

    public var linearVelocity:Vec2;
    public var angularVelocity:Float;
    public var force:Vec2;
    public var torque:Float;

    public function new (){}
}
