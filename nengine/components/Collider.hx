package nengine.components;
import ecs.Entity;
import ecs.Component;
import ecs.Signal;
import nengine.math.*;
import nengine.systems.PhysicsSystem;
import nengine.components.shapes.*;
import nengine.physics.collision.EntityCell;

class Collider implements Component
{
    // Component Data
    public inline static var componentName = "Collider";
    public var name(default, never) = componentName;
    public var shapes:Array<Shape>;
    public var cell(default, null):EntityCell;
    public var entity:Entity;
    public var isTrigger:Bool;

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
            upperBound = if(upperBound == null) shapeAABB.upperBound else Vec2.min(shapeAABB.upperBound, upperBound);
            lowerBound = if(lowerBound == null) shapeAABB.lowerBound else Vec2.max(shapeAABB.lowerBound, lowerBound);
        }
        return new AABB2(upperBound, lowerBound);
    }
}
