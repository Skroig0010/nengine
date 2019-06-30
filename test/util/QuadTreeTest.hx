package test.util;
import utest.Test;
import utest.Assert;
import ecs.Entity;
import nengine.math.*;
import nengine.components.*;
import nengine.physics.collision.shapes.*;
import nengine.physics.collision.QuadTree;
import nengine.systems.*;

@:access(nengine.physics.collision.QuadTree)
class QuadTreeTest extends Test
{
    var tree:QuadTree;
    var tree2:QuadTree;

    public function setup()
    {
        tree = new QuadTree(3, new AABB2(new Vec2(0, 0), new Vec2(8, 8)));
        tree2 = new QuadTree(2, new AABB2(new Vec2(0, 0), new Vec2(4, 4)));
    }

    // prefixがtestである必要がある
    public function testLinearTreeLen()
    {
        Assert.equals(1+4+16+64, tree.linearTree.length);
        Assert.equals(1+4+16, tree2.linearTree.length);
    }

    public function testPow2()
    {
        Assert.equals(4, tree.pow2(2));
        Assert.equals(8, tree.pow2(3));
        Assert.equals(16, tree.pow2(4));
    }
    public function testPow4()
    {
        Assert.equals(4, tree.pow4(1));
        Assert.equals(16, tree.pow4(2));
        Assert.equals(64, tree.pow4(3));
    }
    public function testBitSeparate()
    {
        Assert.equals(4, tree.bitSeparate(2));
        Assert.equals(0x55555555, tree.bitSeparate(0xFFFF));
    }
    public function testGetMortonNumber()
    {
        Assert.equals(14, tree.getMortonNumber(new Vec2(2,3)));
        Assert.equals(45, tree.getMortonNumber(new Vec2(3,6)));
    }

    public function testGetLevel()
    {
        Assert.equals(0, tree.getLevel(0x0));
        Assert.equals(1, tree.getLevel(0x1));
        Assert.equals(1, tree.getLevel(0x2));
        Assert.equals(1, tree.getLevel(0x3));
        Assert.equals(2, tree.getLevel(0x4));
        Assert.equals(8, tree.getLevel(0xffff));
    }

    public function testAddToTree()
    {
        var t = new QuadTree(2, new AABB2(new Vec2(0, 0), new Vec2(40, 40)));
        var c1 = new CircleShape(new Vec2(30, 30), 5);
        var c2 = new CircleShape(new Vec2(25, 25), 10);
        t.addShape(c1, new Transform2());
        t.addShape(c2, new Transform2());
        Assert.equals(c2, t.linearTree[0].shape);
        Assert.equals(null, t.linearTree[1]);
        Assert.equals(null, t.linearTree[2]);
        Assert.equals(null, t.linearTree[3]);
        Assert.equals(c1, t.linearTree[4].shape);
        Assert.equals(null, t.linearTree[5]);
        Assert.equals(null, t.linearTree[6]);
        Assert.equals(null, t.linearTree[7]);
        Assert.equals(null, t.linearTree[8]);
        Assert.equals(null, t.linearTree[9]);
        Assert.equals(null, t.linearTree[10]);
        Assert.equals(null, t.linearTree[11]);
        Assert.equals(null, t.linearTree[12]);
        Assert.equals(null, t.linearTree[13]);
        Assert.equals(null, t.linearTree[14]);
        Assert.equals(null, t.linearTree[15]);
        Assert.equals(null, t.linearTree[16]);
        Assert.equals(null, t.linearTree[17]);
        Assert.equals(null, t.linearTree[18]);
        Assert.equals(null, t.linearTree[19]);
        Assert.equals(null, t.linearTree[20]);
    }

    public function testCheckHitAll()
    {
        var hitList = new Array<Shape>();
        var t = new QuadTree(2, new AABB2(new Vec2(0, 0), new Vec2(40, 40)));
        var c1 = new CircleShape(new Vec2(30, 30), 5);
        var c2 = new CircleShape(new Vec2(25, 25), 10);
        t.addShape(c1, new Transform2());
        t.addShape(c2, new Transform2());
        t.checkHitAll((shape1, shape2)->
                {
                    hitList.push(shape1);
                    hitList.push(shape2);
                });
        for(e in [c2, c1])
        {
        Assert.equals(e, hitList.pop());
        }
    }
}
