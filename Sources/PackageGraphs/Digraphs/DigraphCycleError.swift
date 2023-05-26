/// At least one dependency cycle exists in the relevant digraph.
public
struct DigraphCycleError<Node>:Error, Equatable, Sendable where Node:DigraphNode
{
    public
    init()
    {
    }
}
