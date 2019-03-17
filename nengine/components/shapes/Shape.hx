package nengine.components.shapes;
import nengine.math.*;

interface Shape
{
    public var type(default, never):ShapeType;
    public function computeAABB(transform:Transform2):AABB2;
    public function clone():Shape;
}
