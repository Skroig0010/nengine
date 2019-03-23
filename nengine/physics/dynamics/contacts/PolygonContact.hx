package nengine.physics.dynamics.contacts;

class PolygonContact extends Contact
{
    private function new() { }

    public static function create():Contact
    {
        return new PolygonContact();
    }
}
