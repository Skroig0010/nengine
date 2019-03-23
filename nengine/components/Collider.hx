package nengine.components;
import ecs.Entity;
import ecs.Component;
import ecs.Signal;
import nengine.math.*;
import nengine.systems.PhysicsSystem;
import nengine.physics.collision.shapes.*;
import nengine.physics.collision.ContactEdge;
import nengine.physics.collision.ShapeCell;
import nengine.physics.collision.QuadTree;
import nengine.physics.collision.HitCallBack;

class Collider implements Component
{
    // Component Data
    public inline static var componentName = "Collider";
    public var name(default, never) = componentName;
    public var entity:Entity;
    public var contactEdges:ContactEdge = null;

    private var shapes:Array<Shape>;

    public function new(entity:Entity, shapes:Array<Shape>)
    {
        this.entity = entity;
        this.shapes = shapes;
    }

    public function addShapes(tree:QuadTree, shapes:Array<Shape>):Void
    {
        var transform = cast(entity.getComponent(Transform.componentName), Transform).global;
        for(shape in shapes)
        {
            tree.addShape(shape, transform);
            shapes.push(shape);
        }
    }

    public function removeShapes(tree:QuadTree, shapes:Array<Shape>):Void
    {
        for(shape in shapes)
        {
            tree.removeShape(shape);
            shapes.remove(shape);
        }
    }

    // 使わなさそう
    // public function updateShape(tree:QuadTree, shape:Shape):Void

    public function updateShapes(tree:QuadTree, listener:HitCallBack):Void
    {
        var transform = cast(entity.getComponent(Transform.componentName), Transform).global;
        for(shape in shapes)
        {
            tree.removeShape(shape);
            tree.addShape(shape, transform);
            tree.checkHit(shape, listener);
        }
    }

    public function addToTree(tree:QuadTree):Void
    {
        var transform = cast(entity.getComponent(Transform.componentName), Transform).global;
        for(shape in shapes)
        {
            tree.addShape(shape, transform);
        }
    }

    public function removeFromTree(tree:QuadTree):Void
    {
        for(shape in shapes)
        {
            tree.removeShape(shape);
        }
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
