package nengine.physics.dynamics;
import ecs.Entity;
import nengine.components.Transform;
import nengine.math.Vec2;
import nengine.math.Transform2;
import nengine.physics.collision.shapes.AABB2;
import nengine.physics.collision.shapes.Shape2;
import nengine.physics.collision.shapes.MassData;
import nengine.physics.collision.BroadPhase2;
import nengine.physics.collision.DynamicTree2Node;

class Fixture2
{
    public var shape(default, null):Shape2;
    public var friction(default, default):Float;
    public var restitution(default, default):Float;
    public var density(default, default):Float;
    public var isSensor:Float;
    public var proxy(default, null):DynamicTree2Node;
    public var proxyCount(default, null):Int;
    public var aabb(default, null):AABB2;

    private var entity:Entity;

    public function new(shape:Shape2, friction:Float, restitution:Float, density:Float, entity:Entity, ?isSensor:Bool = false)
    {
        this.shape = shape;
        this.friction = friction;
        this.restitution = restitution;
        this.density = density;
        this.entity = entity;

        proxyCount = 0;
    }

    public function createProxy(broadPhase:BroadPhase2, transform:Transform2):Void
    {
      aabb = shape.computeAABB(transform);
      proxy = broadPhase.createProxy(aabb);
    }

    public function destroyProxy(broadPhase:BroadPhase2):Void
    {
        if (proxy == null) {
            return;
        }
        broadPhase.destroyProxy(proxy);
        proxy = null;
    }

    inline public function testPoint(point:Vec2):Bool
    {
        return shape.testPoint(cast (entity.getComponent("Transform"), Transform).global, point);
    }

    inline public function getMassData():MassData
    {
        return shape.computeMass(density);
    }
}
