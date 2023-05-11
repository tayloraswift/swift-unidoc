import Repositories

extension SymbolGraph
{
    @frozen public
    struct Product:Identifiable, Equatable, Sendable
    {
        public
        let id:ProductIdentifier

        public
        let modules:[ModuleIdentifier]
        public
        let type:ProductType

        @inlinable public
        init(id:ProductIdentifier, modules:[ModuleIdentifier], type:ProductType)
        {
            self.id = id
            self.modules = modules
            self.type = type
        }
    }
}
