package test.math;
import utest.Test;
import utest.Assert;
import haxe.ds.Option;
import nengine.ds.RedBlackTree;

@:access(nengine.ds.RedBlackTree)
class RedBlackTreeTest extends Test
{
    public function testAdd()
    {
        var comp = (x, y)-> x-y;
        var eset = new RedBlackTree<Int>(comp);
        for(i in 0...10)
        {
            eset = eset.add(i);
        }
        for(i in 0...10)
        {
            Assert.isTrue(eset.has(i));
        }
        for(i in 10...20)
        {
            Assert.isFalse(eset.has(i));
        }
    }

    public function testRemove()
    {
        var comp = (x, y)-> x-y;
        var eset = new RedBlackTree<Int>(comp);
        for(i in 0...10)
        {
            eset = eset.add(i);
        }
        for(i in 0...10)
        {
            eset = eset.remove(9-i);
        }
        for(i in 0...10)
        {
            Assert.isFalse(eset.has(i));
        }
        eset = eset.add(0);
        eset = eset.add(1);
        eset = eset.remove(1);
        eset = eset.remove(0);
        Assert.isFalse(eset.has(0));
        Assert.isFalse(eset.has(1));
    }

    public function testLowerHigher()
    {
        var comp = (x, y)-> x-y;
        var eset = new RedBlackTree<Int>(comp);
        for(i in 0...100)
        {
            eset = eset.add(i);
        }
        for(i in 1...100)
        {
            switch(eset.lower(i))
            {
                case Some(x):
                    Assert.equals(i-1, x);
                    Assert.equals(eset, if(x == i-1) eset else null);
                default:
                    Assert.isTrue(false);
            }
        }
        for(i in 0...99)
        {
            switch(eset.higher(i))
            {
                case Some(x):
                    Assert.equals(i+1, x);
                    Assert.equals(eset, if(x == i+1) eset else null);
                default:
                    Assert.isTrue(false);
            }
        }
        Assert.equals(None, eset.lower(0));
        Assert.equals(None, eset.higher(99));
    }
}
