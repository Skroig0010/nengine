package nengine.components;
import nengine.math.*;

interface Transformable<T>
{
    public var local(default, default):T;
    public var global(get, set):T;
    public var parent(default, default):Transformable<T>;
}
