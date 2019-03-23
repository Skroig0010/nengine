package nengine.physics.collision;
import haxe.ds.GenericStack;
import ecs.Entity;
import nengine.components.Collider;
import nengine.components.Transform;
import nengine.math.*;
import nengine.physics.collision.shapes.Shape;

class QuadTree
{
    private var linearTree = new Array<ShapeCell>();
    // 分割数
    private var maxLevel:Int;

    private var area:AABB2;

    public function new(maxLevel:Int, area:AABB2)
    {
        if(maxLevel < 0)throw "QuadTree level should be 0 or over.";
        this.maxLevel = maxLevel;
        this.area = area;
        for(_ in 0...getSpaceNumber(maxLevel))
        {
            linearTree.push(null);
        }
    }

    // TODO:ColliderのFamilyにEntityが追加されたときに呼ぶメソッドはなくなったので新たになんか考えなきゃいけない
    // TODO:ColliderのShapeのリストにShapeが追加されたら自動で木に追加するみたいな感じならどうでしょう
    public function addShape(shape:Shape, transform:Transform2):Void
    {
        var cell = shape.cell;
        var aabb = shape.computeAABB(transform);
        var r = new Vec2(BroadPhase.aabbExtension, BroadPhase.aabbExtension);
        var fatAABB = new AABB2(aabb.upperBound - r, aabb.lowerBound + r);
        cell.fatAABB = fatAABB;
        addToLinearTree(cell, getTreeIndex(fatAABB));
    }

    public function removeShape(shape:Shape):Void
    {
        removeFromLinearTree(shape.cell);
    }


    // 4分木内のオブジェクト全て対与えられたEntityとの衝突判定を行う
    public function checkHit(shape:Shape, listener:HitCallBack):Void
    {
        var cell = shape.cell;
        var treeIndex = if(cell.parentId != -1) cell.parentId else getTreeIndex(cell.fatAABB);
        var depth = getLevel(treeIndex);
        treeIndex -= getSpaceNumber(depth - 1);
        // indexより上位の空間と衝突判定
        var currentTreeIndex = treeIndex;
        for(minusDepth in 0... depth)
        {
            currentTreeIndex = currentTreeIndex >> 2;
            // currentTreeIndex内のEntityとの衝突判定 
            checkHitList(cell, linearTree[currentTreeIndex + getSpaceNumber(depth - minusDepth - 1)], listener);
        }

        // index含む下位の空間があれば衝突判定
        checkHit2(cell, treeIndex, depth, listener);
    }

    private function checkHit2(cell:ShapeCell, currentTreeIndex:Int, depth:Int, listener:HitCallBack):Void
    {
        checkHitList(cell, linearTree[currentTreeIndex + getSpaceNumber(depth - 1)], listener);

        // 下位空間が範囲外なら終了
        if(maxLevel <= depth) return;

        var checkNum = currentTreeIndex << 2;

        for(index in 0...4)
        {
            checkHit2(cell, checkNum + index, depth + 1, listener);
        }
    }

    // 4分木内のオブジェクト全て対全ての衝突判定を行う
    public function checkHitAll(listener:HitCallBack):Void
    {
        var currentTreeIndex = 0;
        var indexStack = new GenericStack<Int>();
        checkHitAll2(currentTreeIndex, indexStack, 0, listener);
    }

    private function checkHitAll2(currentTreeIndex:Int, indexStack:GenericStack<Int>, depth:Int, listener:HitCallBack):Void
    {
        // 現在の空間の最初のcellを取得
        var cellA = linearTree[currentTreeIndex + getSpaceNumber(depth - 1)];

        while(cellA != null){
            // 同じ空間内のEntityとの衝突判定
            var cellB = cellA.next;
            checkHitList(cellA, cellB, listener);

            // スタックに登録されているEntityとの衝突判定
            for(index in indexStack)
            {
                cellB = linearTree[index];
                checkHitList(cellA, cellB, listener);
            }

            cellA = cellA.next;
        }

        // 下位空間が範囲外なら終了
        if(maxLevel <= depth) return;

        var checkNum = currentTreeIndex << 2;

        // スタックに現在の空間をpush
        indexStack.add(currentTreeIndex + getSpaceNumber(depth - 1));

        // 下位空間の探索
        for(index in 0...4)
        {
            checkHitAll2(checkNum + index, indexStack, depth + 1, listener);
        }
        indexStack.pop();
        return;
    }

    private function checkHitList(cellA:ShapeCell, cells:ShapeCell, listener:HitCallBack):Void
    {
        var cellB = cells;
        while(cellB != null)
        {
            // TODO:AABB判定したあとContact作成
            if(cellA != cellB && Collision.collideAABBs(cellA.fatAABB, cellB.fatAABB))
            {
                listener(cellA.collider, cellA.shape, cellB.collider, cellB.shape);
            }
            cellB = cellB.next;
        }
    }

    private function getTreeIndex(aabb:AABB2):Int
    {
        var mortonA = getMortonNumber(aabb.upperBound);
        var mortonB = getMortonNumber(aabb.lowerBound);
        var ms = mortonA ^ mortonB;
        var mask = 0x00000003;
        var result = 0;
        for(i in 1...maxLevel + 1)
        {
            if(ms & mask != 0)result = i;
            mask = mask << 2;
        }
        var level = maxLevel - result;
        var index = mortonA >> (result * 2);
        return index + getSpaceNumber(level - 1);
    }

    private function getLevel(index:Int):Int
    {
        var result = 0;
        while(index != 0)
        {
            result++;
            index = index >> 2;
        }
        return  result;
    }

    private function getMortonNumber(point:Vec2):Int
    {
        var top = area.upperBound.y;
        var left = area.upperBound.x;
        var bottom = area.lowerBound.y;
        var right = area.lowerBound.x;
        // セルの大きさ
        var cx = (right - left) / pow2(maxLevel);
        var cy = (bottom - top) / pow2(maxLevel);
        // 格子座標
        var x = Std.int((point.x - left) / cx);
        var y = Std.int((point.y - top) / cy);

        return bitSeparate(x) | (bitSeparate(y) << 1);
    }

    private function bitSeparate(number:Int):Int
    {
        number = (number|number<<8) & 0x00ff00ff;
        number = (number|number<<4) & 0x0f0f0f0f;
        number = (number|number<<2) & 0x33333333;
        return (number|number<<1) & 0x55555555;
    }

    private inline function pow2(x:Int):Int
    {
        return 1 << x;
    }

    private inline function pow4(x:Int):Int
    {
        return 1 << (2 * x);
    }

    private inline function getSpaceNumber(level:Int):Int
    {
        return if(level < 0) 0 else Std.int((pow4(level + 1) - 1)/3);
    }

    private function addToLinearTree(cell:ShapeCell, id:Int):Void
    {
        if(id >= linearTree.length) throw "over QuadTree id";
        cell.parentId = id;
        if(linearTree[id] == null)
        {
            linearTree[id] = cell;
        }
        else
        {
            var temp = linearTree[id];
            cell.next = temp;
            linearTree[id] = cell;
            temp.prev = linearTree[id];
        }
    }

    private function removeFromLinearTree(cell:ShapeCell):Void
    { 
        if(cell == linearTree[cell.parentId])linearTree[cell.parentId] = cell.next;
        if(cell.prev != null)cell.prev.next = cell.next;
        if(cell.next != null)cell.next.prev = cell.prev;
        cell.prev = cell.next = null;
        cell.parentId = -1;
    }
}
