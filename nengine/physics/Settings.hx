package nengine.physics;

class Settings
{
    static public var aabb2Extension(default, never):Float = 0.1;
    static public var aabb2Multiplier(default, never):Float = 2.0;
    
    static public function assert(cond:Bool):Void
    {
        if (!cond) {
            throw "Assertion Failed";
        }
    }
}
