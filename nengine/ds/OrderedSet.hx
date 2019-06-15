package nengine.math;

interface OrderedSet<T> extends Set<T>
{
    public function first():Option<T>;
    public function last():Option<T>;
}
