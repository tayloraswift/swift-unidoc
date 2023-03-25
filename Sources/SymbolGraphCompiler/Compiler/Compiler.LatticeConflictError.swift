extension Compiler
{
    public
    struct LatticeConflictError<HalfEdge>:Error, Sendable where HalfEdge:Sendable
    {
        public
        let other:HalfEdge

        public
        init(existing other:HalfEdge)
        {
            self.other = other
        }
    }
}
extension Compiler.LatticeConflictError:Equatable where HalfEdge:Equatable
{
}
