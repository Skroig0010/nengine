package nengine.math;

class RedBlackTree<T> implements OrderedSet<T>
{
    private final root:TreeNode<T>;

    public function new(root:TreeNode<T> = Leaf) 
    {
        this.root = root;
    }

    private inline function rotateL(node:TreeNode<T>):TreeNode<T>
    {
        return switch(node)
        {
            case Node(c1, t1, v1, Node(c2, t2, v2, t3)):
                Node(c2, Node(c1, t1, v1, t2), v2, t3);
            default:
                throw {msg:"rotateL failed", node:node, tree:this};
        }
    }

    private inline function rotateR(node:TreeNode<T>):TreeNode<T>
    {
        return switch(node)
        {
            case Node(c2, Node(c1, t1, v1, t2), v2, t3):
                Node(c1, t1, v1, Node(c2, t2, v2, t3));
            default:
                throw {msg:"rotateR failed", node:node, tree:this};
        }
    }

    private inline function rotateLR(node:TreeNode<T>):TreeNode<T>
    {
        return switch(node)
        {
            case Node(c5, Node(c1, t1, v1, Node(c3, t2, v3, t3)), v5, t4):
                Node(c3, Node(c1, t1, v1, t2), v3, Node(c5, t3, v5, t4));
            default:
                throw {msg:"rotateLR failed", node:node, tree:this};
        }
    }

    private inline function rotateRL(node:TreeNode<T>):TreeNode<T>
    {
        return switch(node)
        {
            case Node(c1, t1, v1, Node(c5, Node(c3, t2, v3, t3), v5, t4)):
                Node(c3, Node(c1, t1, v1, t2), v3, Node(c5, t3, v5, t4));
            default:
                throw {msg:"rotateRL failed", node:node, tree:this};
        }
    }

    public function add(value:T, compare:T -> T -> Int):RedBlackTree<T>
    {
        return new RedBlackTree(makeBlack(ins(root, value, compare)));
    }

    private function ins(node:TreeNode<T>, v1:T, compare:T -> T -> Int):TreeNode<T>
    {
        return switch(node) 
        {
            case Node(c, t1, v2, t2) if(compare(v1, v2) < 0):
                balance(Node(c, ins(t1, v1, compare), v2, t2));
            case Node(c, t1, v2, t2) if(compare(v1, v2) == 0):
                node;
            case Node(c, t1, v2, t2):
                balance(Node(c, t1, v2, ins(t2, v1, compare)));
            case Leaf:
                Node(Red, Leaf, v1, Leaf);
        }
    }

    private function makeBlack(node:TreeNode<T>):TreeNode<T>
    {
        return switch(node)
        {
            case Node(_, t1, v, t2):
                Node(Black, t1, v, t2);
            case Leaf:
                Leaf;
        }
    }

    private function balance(node:TreeNode<T>):TreeNode<T>
    {
        return switch(node)
        {
            case  Node(Black, Node(Red, Node(Red, t1, v1, t2), v2, t3), v3, t4)
                | Node(Black, Node(Red, t1, v1, Node(Red, t2, v2, t3)), v3, t4)
                | Node(Black, t1, v1, Node(Red, Node(Red, t2, v2, t3), v3, t4))
                | Node(Black, t1, v1, Node(Red, t2, v2, Node(Red, t3, v3, t4))):
                    Node(Red, Node(Black, t1, v1, t2), v2, Node(Black, t3, v3, t4));
            case Node(_, _, _, _):
            node;
            default:
            throw {msg:"balance failed", node:node, tree:this};
        }
    }

    public function remove(value:T, compare:T -> T -> Int):RedBlackTree<T>
    {
        return new RedBlackTree(makeBlack(del(root, value, compare)));
    }

    private function del(node:TreeNode<T>, v1:T, compare:T -> T -> Int):TreeNode<T>
    {
        return switch(node)
        {
            case Node(_, t1, v2, t2) if(compare(v1, v2) < 0):
                delL(v1, node, compare);
            case Node(_, t1, v2, t2) if(compare(v1, v2) > 0):
                delR(v1, node, compare);
            case Node(_, t1, v2, t2):
                fuse(t1, t2);
            default:
                throw {msg:"del failed", node:node, tree:this};
        }
    }

    private function delL(v:T, node:TreeNode<T>, compare:T -> T -> Int):TreeNode<T>
    {
        return switch(node)
        {
            case Node(Black, t1, v1, t2):
                balL(Node(Black, del(t1, v, compare), v1, t2));
            case Node(Red, t1, v1, t2):
                Node(Red, del(t1, v, compare), v1, t2);
            default:
                throw {msg:"delL failed", node:node, tree:this};
        }
    }

    private function balL(node:TreeNode<T>):TreeNode<T>
    {
        return switch(node)
        {
            case Node(Black, Node(Red, t1, v1, t2), v2, t3):
                Node(Red, Node(Black, t1, v1, t2), v2, t3);
            case Node(Black, t1, v1, Node(Black, t2, v2, t3)):
                balance(Node(Black, t1, v1, Node(Red, t2, v2, t3)));
            case Node(Black, t1, v1, Node(Red, Node(Black, t2, v2, t3), v3, Node(Black, t4, v4, t5))):
                Node(Red, Node(Black, t1, v1, t2), v2, balance(Node(Black, t3, v3, Node(Red, t4, v4, t5))));
            default:
                throw {msg:"balL failed", node:node, tree:this};
        }
    }

    private function delR(v:T, node:TreeNode<T>, compare:T -> T -> Int):TreeNode<T>
    {
        return switch(node)
        {
            case Node(Black, t1, v1, t2):
                balR(Node(Black, t1, v1, del(t2, v, compare)));
            case Node(Red, t1, v1, t2):
                Node(Red, t1, v1, del(t2, v, compare));
            default:
                throw {msg:"delR failed", node:node, tree:this};
        }
    }

    private function balR(node:TreeNode<T>):TreeNode<T>
    {
        return switch(node)
        {
            case Node(Black, t1, v1, Node(Red, t2, v2, t3)):
                Node(Red, t1, v1, Node(Black, t2, v2, t3));
            case Node(Black, Node(Black, t1, v1, t2), v2, t3):
                balance(Node(Black, Node(Red, t1, v1, t2), v2, t3));
            case Node(Black, Node(Red, Node(Black, t1, v1, t2), v2, Node(Black, t3, v3, t4)), v4, t5):
                Node(Red, balance(Node(Black, Node(Red, t1, v1, t2), v2, t3)), v3, Node(Black, t4, v4, t5));
            default:
                throw {msg:"balR failed", node:node, tree:this};
        }
    }

    private function fuse(node1:TreeNode<T>, node2:TreeNode<T>):TreeNode<T>
    {
        return switch([node1, node2])
        {
            case [Leaf, t] | [t, Leaf]:
                t;
            case [Node(Black, _, _, _), Node(Red, t1, v1, t2)]:
                Node(Red, fuse(node1, t1), v1, t2);
            case [Node(Red, t1, v1, t2), Node(Black, _, _, _)]:
                Node(Red, t1, v1, fuse(t2, node2));
            case [Node(Red, t1, v1, t2), Node(Red, t3, v2, t4)]:
                var s = fuse(t2, t3);
                switch(s)
                {
                    case Node(Red, s1, v3, s2):
                        Node(Red, Node(Red, t1, v1, s1), v3, Node(Red, s2, v2, t4));
                    case Node(Black, _, _, _):
                        Node(Red, t1, v1, Node(Red, s, v2, t4));
                    default:
                        throw {msg:"switch1 in fuse failed", node:s, tree:this};
                }
            case [Node(Black, t1, v1, t2), Node(Black, t3, v2, t4)]:
                var s = fuse(t2, t3);
                switch(s)
                {
                    case Node(Red, s1, v3, s2):
                        Node(Red, Node(Black, t1, v1, s1), v3, Node(Black, s2, v2, t4));
                    case Node(Black, s1, v3, s2):
                        balL(Node(Black, t1, v1, Node(Black, s, v2, t4)));
                    default:
                        throw {msg:"switch2 in fuse failed", node:s, tree:this};
                }
        }
    }

    public function has(element:T, compare:T -> T -> Int):Bool
    {
        var node = root;
        while(true)
        {
            switch(node)
            {
                case Node(_, t1, v, t2) if(compare(element, v) < 0):
                    node = t1;
                case Node(_, t1, v, t2) if(compare(element, v) == 0):
                    return true;
                case Node(_, t1, v, t2) :
                    node = t2;
                case Leaf:
                    return false;
            }
        }
        return false;
    }

    private inline function nodeToOption(node:TreeNode<T>):Option<T>
    {
        return switch(node)
        {
            case Node(_, _, v, _):
                Some(v);
            case Leaf:
                None;
        }
    }

    public function first():Option<T>
    {
        var node = root;
        while(true)
        {
            switch(node)
            {
                case Node(_, Leaf, _, _) | Leaf:
                    break;
                case Node(_, t, _, _):
                    node = t;
            }
        }
        return nodeToOption(node);
    }

    public function last():Option<T>
    {
        var node = root;
        while(true)
        {
            switch(node)
            {
                case Node(_, _, _, Leaf) | Leaf:
                    break;
                case Node(_, _, _, t):
                    node = t;
            }
        }
        return nodeToOption(node);
    }
}

private enum Color
{
    Red;
    Black;
}

private enum TreeNode<T>
{
    Node(color:Color, lst:TreeNode<T>, value:T, rst:TreeNode<T>);
    Leaf;
}
