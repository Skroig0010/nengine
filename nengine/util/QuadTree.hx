package nengine.util;
import haxe.ds.GenericStack;
import ecs.Entity;
import nengine.components.*;
import nengine.math.*;

class QuadTree implements SpatialPartitioning
{
    private var linearTree = new Array<EntityCell>();
    // 分割数
    private var maxLevel:Int;

    private var area:AABB2;

    public function new(maxLevel:Int, area:AABB2)
    {
        this.maxLevel = maxLevel;
        this.area = area;
        for(_ in 0...cast((pow4(maxLevel + 1) - 1)/3, Int))
        {
            linearTree.push(null);
        }
    }
    // 任意のMover同士の衝突判定
    // RigidBodyのFamilyにEntityが追加されたときに呼ぶメソッド
    public function onEntityAdded(entity:Entity):Void
    {
        addToTree(entity);
    }

    public function onEntityRemoved(entity:Entity):Void
    {
        removeFromLinearTree(entity);
    }

    public function checkHit(collisionCheck:Entity->Entity->Void):Void
    {
        var currentTreeIndex = 0;
        var indexStack = new GenericStack<Int>();
        checkHit2(collisionCheck, currentTreeIndex, indexStack, 0);
    }

    private function checkHit2(collisionCheck:Entity->Entity->Void, currentTreeIndex:Int, indexStack:GenericStack<Int>, depth:Int):Void
    {
        // 現在の空間の最初のcellを取得
        var cellA = linearTree[currentTreeIndex];

        while(cellA != null){
            // 同じ空間内のEntityとの衝突判定
            var cellB = cellA.next;
            while(cellB != null)
            {
                collisionCheck(cellA.entity, cellB.entity);
                cellB = cellB.next;
            }

            // スタックに登録されているEntityとの衝突判定
            for(index in indexStack)
            {
                cellB = linearTree[index];
                while(cellB != null)
                {
                    collisionCheck(cellA.entity, cellB.entity);
                    cellB = cellB.next;
                }
            }

            cellA = cellA.next;
        }

        var checkNum = (currentTreeIndex << 2) + Std.int((pow4(depth) - 1) / 3);

        // 下位空間のindexが範囲外なら終了
        if(linearTree.length <= checkNum) return;

        // スタックに現在の空間をpush
        indexStack.add(currentTreeIndex);

        // 下位空間の探索
        for(index in 0...4)
        {
            checkHit2(collisionCheck, checkNum + index, indexStack, depth + 1);
        }
        indexStack.pop();
        return;
    }

    private function addToTree(entity:Entity):Void
    {
        var transform = cast(entity.getComponent(Transform.componentName), Transform);
        var body = cast(entity.getComponent(RigidBody.componentName), RigidBody);
        var aabb = body.getAABB(transform.global);

        var mortonA = getMortonNumber(aabb.upperBound);
        var mortonB = getMortonNumber(aabb.lowerBound);
        addToLinearTree(entity, getIndex(mortonA, mortonB));
    }

    private function getIndex(mortonA:Int, mortonB:Int):Int
    {
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
        return index + Std.int((pow4(level) - 1)/3);
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

    private function addToLinearTree(entity:Entity, id:Int):Void
    {
        if(id >= linearTree.length) throw "over QuadTree id";
        var body = cast(entity.getComponent(RigidBody.componentName), RigidBody);
        body.cell.parentId = id;
        if(linearTree[id] == null)
        {
            linearTree[id] = body.cell;
        }
        else
        {
            var temp = linearTree[id];
            body.cell.next = temp;
            linearTree[id] = body.cell;
            temp.prev = linearTree[id];
        }
    }

    private function removeFromLinearTree(entity:Entity):Void
    { 
        var body = cast(entity.getComponent(RigidBody.componentName), RigidBody);
        body.cell.prev.next = body.cell.next;
        body.cell.next.prev = body.cell.prev;
    }
}
