import SymbolGraphParts
import TraceableErrors

extension Compiler
{
    public
    struct EdgeError:Error, Sendable
    {
        public
        let relationship:SymbolRelationship
        public
        let underlying:any Error

        public
        init(underlying:any Error, in relationship:SymbolRelationship)
        {
            self.underlying = underlying
            self.relationship = relationship
        }
    }
}
extension Compiler.EdgeError:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.relationship == rhs.relationship && lhs.underlying == rhs.underlying
    }
}
extension Compiler.EdgeError:TraceableError
{
    public
    var notes:[String]
    {
        ["While validating relationship \(self.relationship)"]
    }
}
