public
enum DigraphNodeError<Node>:Error, Equatable where Node:DigraphNode
{
    case duplicate(Node.ID)
    case undefined(Node.ID)
}
extension DigraphNodeError:Sendable where Node.ID:Sendable
{
}
