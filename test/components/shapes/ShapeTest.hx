package test.components.shapes;
import utest.Test;
import utest.Assert;
import ecs.Entity;
import nengine.math.*;
import nengine.components.*;
import nengine.components.shapes.*;

@:access(nengine.components.shapes.CircleShape)
class ShapeTest extends Test
{
    public function testCircleAABB()
    {
        var c = new CircleShape(new Vec2(1, 1), 5);
        var aabb = c.computeAABB(new Transform2(new Vec2(10, 4), new Rot2(Math.PI/4)));
        Assert.equals(10 - 5, aabb.upperBound.x);
        Assert.equals(4 + Math.sqrt(2) - 5, aabb.upperBound.y);
        Assert.equals(10 + 5, aabb.lowerBound.x);
        Assert.equals(4 + Math.sqrt(2) + 5, aabb.lowerBound.y);
    }
}
