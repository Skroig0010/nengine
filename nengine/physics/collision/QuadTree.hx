package nengine.physics.collision;
import haxe.ds.GenericStack;
import ecs.Entity;
import nengine.components.*;
import nengine.math.*;

class QuadTree
{
    private var linearTree = new Array<EntityCell>();
    // 分割数
    private var maxLevel:Int;

    private var area:AABB2;

    public function new(maxLevel:Int, area:AABB2)
    {
        this.maxLevel = maxLevel;
        this.area = area;
        for(_ in 0...getSpaceNumber(maxLevel))
        {
            linearTree.push(null);
        }
    }

    // RigidBodyのFamilyにEntityが追加されたときに呼ぶメソッド
    public function onEntityAdded(entity:Entity):Void
    {
        addToLinearTree(entity, getTreeIndex(entity));
    }

    public function addEntities(entities:Array<Entity>):Void
    {
        for(entity in entities)
        {
            addToLinearTree(entity, getTreeIndex(entity));
        }
    }

    public function onEntityRemoved(entity:Entity):Void
    {
        removeFromLinearTree(entity);
    }

    // 4分木内のオブジェクト全て対与えられたEntityとの衝突判定を行う
    public function checkHit(entity:Entity, collisionCheck:Entity->Entity->Void):Void
    {
        // おそらくバグってる
        var treeIndex = getTreeIndex(entity);
        var depth = getLevel(treeIndex);
        treeIndex -= getSpaceNumber(depth - 1);
        // indexより上位の空間と衝突判定
        var currentTreeIndex = treeIndex;
        for(minusDepth in 0... depth)
        {
            currentTreeIndex = currentTreeIndex >> 2;
            // currentTreeIndex内のEntityとの衝突判定 
            checkHitList(collisionCheck, entity, linearTree[currentTreeIndex + getSpaceNumber(depth - minusDepth - 1)]);
        }

        // index含む下位の空間があれば衝突判定
        checkHit2(collisionCheck, entity, treeIndex, depth);
    }

    private function checkHit2(collisionCheck:Entity->Entity->Void, entity:Entity, currentTreeIndex:Int, depth:Int):Void
    {
        checkHitList(collisionCheck, entity, linearTree[currentTreeIndex + getSpaceNumber(depth - 1)]);

        // 下位空間が範囲外なら終了
        if(maxLevel <= depth) return;

        var checkNum = currentTreeIndex << 2;

        for(index in 0...4)
        {
            checkHit2(collisionCheck, entity, checkNum + index, depth + 1);
        }
    }

    // 4分木内のオブジェクト全て対全ての衝突判定を行う
    public function checkHitAll(collisionCheck:Entity->Entity->Void):Void
    {
        var currentTreeIndex = 0;
        var indexStack = new GenericStack<Int>();
        checkHitAll2(collisionCheck, currentTreeIndex, indexStack, 0);
    }

    private function checkHitAll2(collisionCheck:Entity->Entity->Void, currentTreeIndex:Int, indexStack:GenericStack<Int>, depth:Int):Void
    {
        // 現在の空間の最初のcellを取得
        var cellA = linearTree[currentTreeIndex + getSpaceNumber(depth - 1)];

        while(cellA != null){
            // 同じ空間内のEntityとの衝突判定
            var cellB = cellA.next;
            checkHitList(collisionCheck, cellA.entity, cellB);

            // スタックに登録されているEntityとの衝突判定
            for(index in indexStack)
            {
                cellB = linearTree[index];
                checkHitList(collisionCheck, cellA.entity, cellB);
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
            checkHitAll2(collisionCheck, checkNum + index, indexStack, depth + 1);
        }
        indexStack.pop();
        return;
    }

    private function checkHitList(collisionCheck:Entity->Entity->Void, entity:Entity, cells:EntityCell):Void
    {
        var cell = cells;
        while(cell != null)
        {
            collisionCheck(entity, cell.entity);
            cell = cell.next;
        }
    }

    private function getTreeIndex(entity:Entity):Int
    {
        var transform = cast(entity.getComponent(Transform.componentName), Transform);
        var body = cast(entity.getComponent(RigidBody.componentName), RigidBody);
        var aabb = body.getAABB(transform.global);

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

    private function addToLinearTree(entity:Entity, id:Int):Void
    {
        if(id >= linearTree.length) throw "over QuadTree id";
        var body = cast(entity.getComponent(RigidBody.componentName), RigidBody);
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
