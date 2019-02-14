package nengine.physics.collision;
import nengine.math.*;
import nengine.physics.collision.shapes.AABB2;
import nengine.physics.dynamics.Fixture2;

class BroadPhase2
{
    private var tree:DynamicTree2;
    private var moveBuffer:Array<DynamicTree2Node>;
    private var pairBuffer:Array<Pair2>;
    public var proxyCount(default, null):Int;
    public var pairCount(default, null):Int;

    public function createProxy(aabb:AABB2):DynamicTree2Node
    {
        var proxy = tree.createProxy(aabb);
        proxyCount++;
        bufferMove(proxy);
        return proxy;
    }

    public function destroyProxy(proxy:DynamicTree2Node):Void
    {
        unBufferMove(proxy);
        proxyCount--;
        tree.destroyProxy(proxy);
    }

    public function moveProxy(proxy:DynamicTree2Node, aabb:AABB2, displacement:Vec2):Void
    {
        var buffer = tree.moveProxy(proxy, aabb, displacement);
        if (buffer) {
            bufferMove(proxy);
        }
    }

    public function testOverlap(proxyA:DynamicTree2Node, proxyB:DynamicTree2Node):Bool
    { 
        return AABB2.testOverlap(
                tree.getFatAABB(proxyA),
                tree.getFatAABB(proxyB)
                );
    }

    public function getFatAABB(proxy:DynamicTree2Node):AABB2
    {
        return tree.getFatAABB(proxy);
    }

    public function updatePairs(callback:Fixture2->Fixture2->Void):Void
    {
        pairCount = 0;
        var queryProxy:DynamicTree2Node;
        for (queryProxy in moveBuffer) {

            function queryCallback(proxy:DynamicTree2Node) {
                if (proxy == queryProxy) return true;
                if (pairCount == pairBuffer.length) {
                    pairBuffer[pairCount] = {
                        proxyA:null,
                        proxyB:null,
                    };
                }
                var pair = pairBuffer[pairCount];
                pair.proxyA = if(proxy.id < queryProxy.id) proxy else queryProxy;
                pair.proxyB = if(proxy.id >= queryProxy.id) proxy else queryProxy;
                ++pairCount;
                return true;
            };
            var fatAABB = tree.getFatAABB(queryProxy);
            tree.query(queryCallback, fatAABB);
        }

        moveBuffer = [];
        var i = 0;
        while (i < pairCount) {
            var primaryPair = pairBuffer[i];
            callback(primaryPair.proxyA.fixture, primaryPair.proxyB.fixture);
            ++i;
            while (i < pairCount) {
                var pair = pairBuffer[i];
                if (pair.proxyA != primaryPair.proxyA || pair.proxyB != primaryPair.proxyB) {
                    break;
                }
                ++i;
            }
        }
    }

    public function query(callback:DynamicTree2Node->Bool, aabb:AABB2):Void
    {
        tree.query(callback, aabb);
    }

    public function rayCast(callback:RayCastInput2->DynamicTree2Node->Float, input:RayCastInput2):Void
    {
        tree.rayCast(callback, input);
    }

    public function validate():Void{
        // 未実装？
    }

    public function rebalance(?iterations:Int = 0):Void
    {
        tree.rebalance(iterations);
    }

    private function bufferMove(proxy:DynamicTree2Node):Void
    {
        moveBuffer[moveBuffer.length] = proxy;
    }

    private function unBufferMove(proxy:DynamicTree2Node):Void
    {
        var i = moveBuffer.indexOf(proxy);
        moveBuffer.splice(i, 1);
    }

    public function comparePairs(pairA:Pair2, pairB:Pair2):Int
    {
        // 未実装？
        return 0;
    }
}
