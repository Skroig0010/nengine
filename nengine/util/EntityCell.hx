package nengine.util;

import ecs.Entity;

class EntityCell
{
    public var parentId:Int;
    public var entity:Entity;
    public var next:EntityCell;
    public var prev:EntityCell;

    public function new(entity:Entity, ?parentId:Int = 0, ?next:EntityCell = null, ?prev:EntityCell = null)
    {
        this.parentId = parentId;
        this.entity = entity;
        this.next = next;
        this.prev = prev;
    }
}
