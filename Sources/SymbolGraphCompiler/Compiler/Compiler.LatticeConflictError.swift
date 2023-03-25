extension Compiler
{
    public
    struct LatticeConflictError<LatticeVector>:Error, Sendable where LatticeVector:Sendable
    {
        public
        let other:LatticeVector

        public
        init(existing other:LatticeVector)
        {
            self.other = other
        }
    }
}
extension Compiler.LatticeConflictError:Equatable where LatticeVector:Equatable
{
}
