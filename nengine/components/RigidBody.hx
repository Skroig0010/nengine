package nengine.components;
import ecs.Entity;
import ecs.Component;
import ecs.Signal;
import nengine.math.*;
import nengine.systems.PhysicsSystem;
import nengine.components.shapes.*;
import nengine.physics.collision.EntityCell;

// Box2Dのbody
class RigidBody implements Component
{
    // Component Data
    public inline static var componentName = "RigidBody";
    public var name(default, never) = componentName;
    public var shapes:Array<Shape>;
    public var cell(default, null):EntityCell;
    public var entity:Entity;
    @:isVar public var invMass(default, set):Float;
    @:isVar public var mass(default, set):Float; 
    private function set_invMass(invMass:Float):Float
    {
        if(invMass != 0) 
        {
            mass = 1 / invMass;
        }
        else
        {
            mass = Math.POSITIVE_INFINITY;
        }

        this.invMass = invMass;
        return invMass;
    }

    private function set_mass(mass:Float):Float
    {
        if(mass != 0)
        {
            invMass = 1 / mass;
        }
        else
        {
            invMass = Math.POSITIVE_INFINITY;
        }
        this.mass = mass;
        return mass;
    }

    public function new(entity:Entity, shapes:Array<Shape>)
    {
        this.entity = entity;
        this.shapes = shapes.map((shape) -> shape.clone());
        cell = new EntityCell(entity);
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
