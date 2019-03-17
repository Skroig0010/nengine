package nengine.physics.collision;

import ecs.Entity;

class EntityCell
{
    public var entity:Entity;
    public var next:EntityCell;
    public var prev:EntityCell;
    public var parentId:Int;

    public function new(entity:Entity, ?parentId:Int = 0, ?next:EntityCell = null, ?prev:EntityCell = null)
    {
        this.entity = entity;
        this.parentId = parentId;
        this.next = next;
        this.prev = prev;
    }
}
