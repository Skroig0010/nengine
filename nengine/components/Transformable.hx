package nengine.components;
import nengine.math.*;

interface Transformable<T>
{
    public var local:T;
    public var global(get, set):T;
    public var parent:Transformable<T>;
}
