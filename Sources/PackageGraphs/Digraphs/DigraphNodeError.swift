public
enum DigraphNodeError<Node>:Error, Equatable where Node:DigraphNode, Node.ID:Sendable
{
    case duplicate(Node.ID)
    case undefined(Node.ID)
}
