import TraceableErrors

public
struct SymbolRelationshipError<HalfEdge>:Error, Sendable where HalfEdge:Sendable
{
    public
    let underlying:any Error
    public
    let edge:HalfEdge

    public
    init(underlying:any Error, edge:HalfEdge)
    {
        self.underlying = underlying
        self.edge = edge
    }
}
extension SymbolRelationshipError:Equatable where HalfEdge:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.edge == rhs.edge && lhs.underlying == rhs.underlying
    }
}
extension SymbolRelationshipError:TraceableError
{
    public
    var notes:[String]
    {
        ["While validating edge \(self.edge)"]
    }
}
