package nengine.util;
import ecs.Entity;

interface SpatialPartitioning
{
    // RigidBodyのFamilyにEntityが追加されたときに呼ぶメソッド
    public function onEntityAdded(entity:Entity):Void;
    public function onEntityRemoved(entity:Entity):Void;

    // 重複なくEntity同士の衝突判定を行う
    public function checkHit(collisionCheck:Entity->Entity->Void):Void;
}
