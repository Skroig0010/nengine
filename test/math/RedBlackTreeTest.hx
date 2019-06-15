package test.math;
import utest.Test;
import utest.Assert;
import nengine.math.RedBlackTree;

@:access(nengine.math.RedBlackTree)
class RedBlackTreeTest extends Test
{
    public function testAdd()
    {
        var eset = new RedBlackTree<Int>();
        var comp = (x, y)-> x-y;
        for(i in 0...10)
        {
        eset = eset.add(i, comp);
        }
        for(i in 0...10)
        {
        Assert.isTrue(eset.has(i, comp));
        }
        for(i in 10...20)
        {
        Assert.isFalse(eset.has(i, comp));
        }
        Assert.equals(null, eset.root);
    }
}
