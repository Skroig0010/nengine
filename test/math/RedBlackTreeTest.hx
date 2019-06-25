package test.math;
import utest.Test;
import utest.Assert;
import haxe.ds.Option;
import nengine.ds.RedBlackTree;

@:access(nengine.math.RedBlackTree)
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
            eset = eset.remove(i);
        }
        for(i in 0...10)
        {
            Assert.isFalse(eset.has(i));
        }
    }

    public function testLowerHigher()
    {
        var comp = (x, y)-> x-y;
        var eset = new RedBlackTree<Int>(comp);
        for(i in 0...10)
        {
            eset = eset.add(i);
        }
        for(i in 1...10)
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
        for(i in 0...9)
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
        Assert.equals(None, eset.higher(9));
    }
}
