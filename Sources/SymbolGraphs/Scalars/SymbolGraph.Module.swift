import PackageGraphs

extension SymbolGraph
{
    @frozen public
    struct Module:Identifiable, Equatable, Sendable
    {
        public
        let id:ModuleIdentifier

        public
        var dependencies:ModuleDependencies

        public
        var members:[ScalarAddress]
        public
        var article:Article?

        @inlinable public
        init(id:ModuleIdentifier, dependencies:ModuleDependencies)
        {
            self.id = id

            self.dependencies = dependencies
            self.members = []
            self.article = nil
        }
    }
}
