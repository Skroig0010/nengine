package nengine.physics.collision.shapes;

class ShapeIdCounter
{
    private static var id = 0;
    public static function getId():Int
    {
        return id++;
    }
}
