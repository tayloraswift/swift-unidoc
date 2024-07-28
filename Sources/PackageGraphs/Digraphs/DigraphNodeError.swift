public
enum DigraphNodeError<Node>:Error, Equatable where Node:Identifiable, Node.ID:Sendable
{
    case duplicate(Node.ID)
    case undefined(Node.ID)
}
extension DigraphNodeError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .duplicate(let id):    "Duplicate node: \(id)"
        case .undefined(let id):    "Undefined node: \(id)"
        }
    }
}
