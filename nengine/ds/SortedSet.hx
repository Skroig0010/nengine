package nengine.ds;

interface SortedSet<T> extends Set<T>
{
    public function first():Option<T>;
    public function last():Option<T>;
}
