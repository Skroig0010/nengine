package test.util;
import utest.Test;
import utest.Assert;
import ecs.Entity;
import nengine.math.*;
import nengine.components.*;
import nengine.components.shapes.*;
import nengine.util.QuadTree;

@:access(nengine.util.QuadTree)
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

    public function testAddToTree()
    {
        var t = new QuadTree(2, new AABB2(new Vec2(0, 0), new Vec2(40, 40)));
        var e1 = makeCircleEntity(new Vec2(30, 30), 5);
        var e2 = makeCircleEntity(new Vec2(25, 25), 10);
        t.onEntityAdded(e1);
        t.onEntityAdded(e2);
        Assert.equals(e2, t.linearTree[0].entity);
        Assert.equals(null, t.linearTree[1]);
        Assert.equals(null, t.linearTree[2]);
        Assert.equals(null, t.linearTree[3]);
        Assert.equals(e1, t.linearTree[4].entity);
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

    public function testCheckHit()
    {
        var hitList = new Map<Entity, Entity>();
        var t = new QuadTree(2, new AABB2(new Vec2(0, 0), new Vec2(40, 40)));
        var e1 = makeCircleEntity(new Vec2(30, 30), 5);
        var e2 = makeCircleEntity(new Vec2(25, 25), 10);
        t.onEntityAdded(e1);
        t.onEntityAdded(e2);
        t.checkHit((entity1, entity2)->
                {
                    hitList.set(entity1, entity2);
                });
        Assert.equals(e2, hitList.get(e1));
    }

    function makeCircleEntity(position:Vec2, radius:Float):Entity
    {
        var entity = new Entity();
        entity.addComponent(new Transform(position, new Rot2()));
        entity.addComponent(new RigidBody(entity, [new CircleShape(new Vec2(), radius)]));
        return entity;
    }

}
