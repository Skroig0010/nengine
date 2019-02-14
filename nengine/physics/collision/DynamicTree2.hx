package nengine.physics.collision;
import nengine.math.*;
import nengine.physics.collision.shapes.AABB2;
import nengine.physics.collision.RayCastInput2;
import nengine.physics.dynamics.Fixture2;

class DynamicTree2
{
    public var root:DynamicTree2Node;
    public var freeList:DynamicTree2Node;
    public var path:Int;
    public var insertionCount:Int;

    public function new()
    {
        root = null;
        freeList = null;
        path = 0;
        insertionCount = 0;
    }

    public function createProxy(aabb:AABB2):DynamicTree2Node
    {
        var node = allocateNode();
        var extendX = Settings.aabb2Extension;
        var extendY = Settings.aabb2Extension;
        node.aabb.upperBound.x = aabb.upperBound.x - extendX;
        node.aabb.upperBound.y = aabb.upperBound.y - extendY;
        node.aabb.lowerBound.x = aabb.lowerBound.x + extendX;
        node.aabb.lowerBound.y = aabb.lowerBound.y + extendY;
        insertLeaf(node);
        return node;
    }

    public function destroyProxy(proxy:DynamicTree2Node):Void
    {
        removeLeaf(proxy);
        freeNode(proxy);
    }

    public function moveProxy(proxy:DynamicTree2Node,aabb:AABB2, displacement:Vec2):Bool
    {
        Settings.assert(proxy.isLeaf());
        if (proxy.aabb.contains(aabb)) {
            return false;
        }
        removeLeaf(proxy);
        var extendX = Settings.aabb2Extension + Settings.aabb2Multiplier * (displacement.x > 0 ? displacement.x : (-displacement.x));
        var extendY = Settings.aabb2Extension + Settings.aabb2Multiplier * (displacement.y > 0 ? displacement.y : (-displacement.y));
        proxy.aabb.upperBound.x = aabb.upperBound.x - extendX;
        proxy.aabb.upperBound.y = aabb.upperBound.y - extendY;
        proxy.aabb.lowerBound.x = aabb.lowerBound.x + extendX;
        proxy.aabb.lowerBound.y = aabb.lowerBound.y + extendY;
        insertLeaf(proxy);
        return true;
    }

    public function rebalance(?iterations:Int = 0):Void
    {
        if (root == null) return;
        for (i in 0...iterations) {
            var node = root;
            var bit = 0;
            while (node.isLeaf() == false) {
                node = ((path >> bit) & 1) == 1 ? node.child2 : node.child1;
                bit = (bit + 1) & 31;
            }
            path++;
            removeLeaf(node);
            insertLeaf(node);
        }
    }

    public function getFatAABB(proxy:DynamicTree2Node):AABB2
    {
        return proxy.aabb;
    }

    public function query(callback:DynamicTree2Node->Bool, aabb:AABB2):Void
    {
        if (root == null) return;
        var stack = new Array<DynamicTree2Node>();
        var count = 0;
        stack[count++] = root;
        while (count > 0) {
            var node = stack[--count];
            if (AABB2.testOverlap(node.aabb, aabb)) {
                if (node.isLeaf()) {
                    var proceed = callback(node);
                    if (!proceed) return;
                }
                else {
                    stack[count++] = node.child1;
                    stack[count++] = node.child2;
                }
            }
        }
    }
    public function rayCast(callback:RayCastInput2->DynamicTree2Node->Float, input:RayCastInput2) {
        if (root == null) return;
        var p1 = input.p1;
        var p2 = input.p2;
        var r = p1 - p2;
        r.normalize();
        var v = Vec2.crossFV(1.0, r);
        var abs_v = v.abs();
        var maxFraction = input.maxFraction;
        var segmentAABB = new AABB2(new Vec2(), new Vec2());
        var tX = 0.0;
        var tY = 0.0; 
        tX = p1.x + maxFraction * (p2.x - p1.x);
        tY = p1.y + maxFraction * (p2.y - p1.y);
        segmentAABB.upperBound.x = Math.min(p1.x, tX);
        segmentAABB.upperBound.y = Math.min(p1.y, tY);
        segmentAABB.lowerBound.x = Math.max(p1.x, tX);
        segmentAABB.lowerBound.y = Math.max(p1.y, tY);
        var stack = new Array<DynamicTree2Node>();
        var count = 0;
        stack[count++] = root;
        while (count > 0) {
            var node = stack[--count];
            if (!AABB2.testOverlap(node.aabb, segmentAABB)) {
                continue;
            }
            var c = node.aabb.getCenter();
            var h = node.aabb.getExtents();
            var separation = Math.abs(v.x * (p1.x - c.x) + v.y * (p1.y - c.y)) - abs_v.x * h.x - abs_v.y * h.y;
            if (separation > 0.0) continue;
            if (node.isLeaf()) 
            {
                var subInput:RayCastInput2 = {
                    p1:null,
                    p2:null,
                    maxFraction:0.0,
                };
                subInput.p1 = input.p1;
                subInput.p2 = input.p2;
                subInput.maxFraction = input.maxFraction;
                maxFraction = callback(subInput, node);
                if (maxFraction == 0.0) return;
                if (maxFraction > 0.0) {
                    tX = p1.x + maxFraction * (p2.x - p1.x);
                    tY = p1.y + maxFraction * (p2.y - p1.y);
                    segmentAABB.upperBound.x = Math.min(p1.x, tX);
                    segmentAABB.upperBound.y = Math.min(p1.y, tY);
                    segmentAABB.lowerBound.x = Math.max(p1.x, tX);
                    segmentAABB.lowerBound.y = Math.max(p1.y, tY);
                }
            }
            else 
            {
                stack[count++] = node.child1;
                stack[count++] = node.child2;
            }
        }
    }
    public function allocateNode():DynamicTree2Node
    {
        if (freeList != null) {
            var node = freeList;
            freeList = node.parent;
            node.parent = null;
            node.child1 = null;
            node.child2 = null;
            return node;
        }
        return new DynamicTree2Node();
    }

    private function freeNode(node:DynamicTree2Node) {
        node.parent = freeList;
        freeList = node;
    }

    private function insertLeaf(leaf:DynamicTree2Node) {
        ++insertionCount;
        if (root == null) {
            root = leaf;
            root.parent = null;
            return;
        }
        var center = leaf.aabb.getCenter();
        var sibling = root;
        if (sibling.isLeaf() == false) {
            do {
                var child1 = sibling.child1;
                var child2 = sibling.child2;
                var norm1 = Math.abs((child1.aabb.upperBound.x + child1.aabb.lowerBound.x) / 2 - center.x) + Math.abs((child1.aabb.upperBound.y + child1.aabb.lowerBound.y) / 2 - center.y);
                var norm2 = Math.abs((child2.aabb.upperBound.x + child2.aabb.lowerBound.x) / 2 - center.x) + Math.abs((child2.aabb.upperBound.y + child2.aabb.lowerBound.y) / 2 - center.y);
                if (norm1 < norm2) {
                    sibling = child1;
                }
                else {
                    sibling = child2;
                }
            }
            while (sibling.isLeaf() == false);
        }
        var node1 = sibling.parent;
        var node2 = allocateNode();
        node2.parent = node1;
        node2.aabb = AABB2.combine(leaf.aabb, sibling.aabb);
        if (node1 != null) {
            if (sibling.parent.child1 == sibling) {
                node1.child1 = node2;
            }
            else {
                node1.child2 = node2;
            }
            node2.child1 = sibling;
            node2.child2 = leaf;
            sibling.parent = node2;
            leaf.parent = node2;
            do {
                if (node1.aabb.contains(node2.aabb)) break;
                node1.aabb = AABB2.combine(node1.child1.aabb, node1.child2.aabb);
                node2 = node1;
                node1 = node1.parent;
            }
            while (node1 != null);
        }
        else {
            node2.child1 = sibling;
            node2.child2 = leaf;
            sibling.parent = node2;
            leaf.parent = node2;
            root = node2;
        }
    }

    private function removeLeaf(leaf:DynamicTree2Node) {
        if (leaf == root) {
            root = null;
            return;
        }
        var node2 = leaf.parent;
        var node1 = node2.parent;
        var sibling;
        if (node2.child1 == leaf) {
            sibling = node2.child2;
        }
        else {
            sibling = node2.child1;
        }
        if (node1 != null) {
            if (node1.child1 == node2) {
                node1.child1 = sibling;
            }
            else {
                node1.child2 = sibling;
            }
            sibling.parent = node1;
            freeNode(node2);
            while (node1 != null) {
                var oldAABB = node1.aabb;
                node1.aabb = AABB2.combine(node1.child1.aabb, node1.child2.aabb);
                if (oldAABB.contains(node1.aabb)) break;
                node1 = node1.parent;
            }
        }
        else {
            root = sibling;
            sibling.parent = null;
            freeNode(node2);
        }
    }
}

