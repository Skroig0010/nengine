package nengine.physics.dynamics.contacts;

class CircleContact extends Contact
{
    private function new() { }

    public static function create():Contact
    {
        return new CircleContact();
    }
}
