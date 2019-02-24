package nengine.physics.collision;

import ecs.Entity;

class EntityCell
{
    public var entity:Entity;
    public var next:EntityCell;
    public var prev:EntityCell;

    public function new(entity:Entity, ?next:EntityCell = null, ?prev:EntityCell = null)
    {
        this.entity = entity;
        this.next = next;
        this.prev = prev;
    }
}
