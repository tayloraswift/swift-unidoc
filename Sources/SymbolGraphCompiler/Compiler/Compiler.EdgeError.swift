import TraceableErrors

extension Compiler
{
    public
    struct EdgeError<Relationship>:Error, Sendable where Relationship:Sendable
    {
        public
        let relationship:Relationship
        public
        let underlying:any Error

        public
        init(underlying:any Error, in relationship:Relationship)
        {
            self.underlying = underlying
            self.relationship = relationship
        }
    }
}
extension Compiler.EdgeError:Equatable where Relationship:Equatable
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
