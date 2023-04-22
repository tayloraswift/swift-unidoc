import Repositories

extension SymbolGraph
{
    @frozen public
    struct Product:Identifiable, Equatable, Sendable
    {
        public
        let id:ProductIdentifier

        public
        let cultures:[ModuleIdentifier]
        public
        let type:ProductType

        @inlinable public
        init(id:ProductIdentifier, cultures:[ModuleIdentifier], type:ProductType)
        {
            self.id = id
            self.cultures = cultures
            self.type = type
        }
    }
}
