package nengine.components;
import ecs.Entity;
import ecs.Component;
import ecs.Signal;
import nengine.components.Transform;
import nengine.math.*;
import nengine.systems.PhysicsSystem;
import nengine.physics.collision.shapes.*;
import nengine.physics.collision.ShapeCell;
import nengine.physics.dynamics.contacts.ContactEdge;

// Box2Dのbody
class RigidBody implements Component
{
    // Component Data
    public inline static var componentName = "RigidBody";
    public var name(default, never) = componentName;
    public var entity:Entity;
    private var shapes:Array<Shape>;

    public var contactEdges:ContactEdge;

    @:isVar public var invMass(default, set):Float;
    @:isVar public var mass(default, set):Float; 
    @:isVar public var inertia(default, set):Float;
    @:isVar public var invInertia(default, set):Float;

    public var transform:Transform2;
    public var force = new Vec2();
    public var torque:Float = 0.0;
    public var linearVelocity = new Vec2();
    public var angularVelocity:Float = 0.0;
    public var linearDamping:Float = 0.0;
    public var angularDamping:Float = 0.0;
    public var gravityScale:Float = 0.0;
    public var localCenter = new Vec2();

    public var type:BodyType = DynamicBody;

    public var system:PhysicsSystem;

    // islandIndex的な
    public var index:Int = 0;

    private inline function invOr0(value:Float):Float
    {
        return if(value != 0)
        {
            1 / value;
        }
        else
        {
            0;
        }
    }

    private function set_invMass(invMass:Float):Float
    {
        mass  = invOr0(invMass);
        return this.invMass = invMass;
    }

    private function set_mass(mass:Float):Float
    {
        invMass = invOr0(mass);
        return this.mass = mass;
    }

    private function set_invInertia(invInertia:Float):Float
    {
        inertia = invOr0(invInertia);
        return this.invInertia = invInertia;
    }

    private function set_inertia(inertia:Float):Float
    {
        invInertia = invOr0(inertia);
        return this.inertia = inertia;
    }

    public function new(entity:Entity, shapes:Array<Shape>, system:PhysicsSystem)
    {
        this.entity = entity;
        this.transform = entity.getComponent(Transform).global;
        for(shape in shapes)
        {
            addShape(shape);
        }
        this.system = system;
    }

    public function addShape(shape:Shape):Void
    {
        shapes.push(shape);
        shape.body = this;
        system.addShape(shape, transform);
    }

    public function removeShape(shape:Shape):Void
    {
        shapes.remove(shape);
        if(shape.body == this)shape.body = null;
        system.removeShape(shape);
    }

    public function getShapesIterator():Iterator<Shape>
    {
        return shapes.iterator();
    }

    public function getAABB(transform:Transform2):AABB2
    {
        var upperBound:Vec2 = null;
        var lowerBound:Vec2 = null;
        for(shape in shapes)
        {
            var shapeAABB = shape.computeAABB(transform);
            if(upperBound == null)
            {
                upperBound = shapeAABB.upperBound;
            }
            else
            {
                upperBound = Vec2.min(shapeAABB.upperBound, upperBound);
            }
            if(lowerBound == null)
            {
                lowerBound = shapeAABB.lowerBound;
            }
            else
            {
                lowerBound = Vec2.max(shapeAABB.lowerBound, lowerBound);
            }
        }
        return new AABB2(upperBound, lowerBound);
    }
}
