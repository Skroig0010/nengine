package nengine.physics.dynamics.contacts;

class PolygonAndCircleContact extends Contact
{
    private function new() { }

    public static function create():Contact
    {
        return new PolygonAndCircleContact();
    }
}
