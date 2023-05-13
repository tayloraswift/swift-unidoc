import PackageGraphs

extension Compiler
{
    @frozen public
    struct Culture:Identifiable, Sendable
    {
        public
        var scalars:[Compiler.Scalar]
        public
        let id:ModuleIdentifier

        init(id:ModuleIdentifier)
        {
            self.id = id
            self.scalars = []
        }
    }
}
