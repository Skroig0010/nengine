package test.physics.collision;
import utest.Test;
import utest.Assert;
import ecs.Entity;
import nengine.math.*;
import nengine.components.*;
import nengine.physics.collision.Collision;

@:access(nengine.physics.collision.Collision)
class CollisionTest extends Test
{
    public function test()
    {
        var s1 = new Segment2(new Vec2(0, 0), new Vec2(100, 0));
        var s2 = new Segment2(new Vec2(99, 0), new Vec2(200, 0));
        var s3 = new Segment2(new Vec2(101, 0), new Vec2(200, 0));
        var s4 = new Segment2(new Vec2(50, -50), new Vec2(50, 50));
        var s5 = new Segment2(new Vec2(0, 1), new Vec2(100, 1));
        Assert.isTrue(Collision.collideSegments(s1, s1));
        Assert.isTrue(Collision.collideSegments(s1, s2));
        Assert.isFalse(Collision.collideSegments(s1, s3));
        Assert.isTrue(Collision.collideSegments(s1, s4));
        Assert.isFalse(Collision.collideSegments(s1, s5));
    }
}
