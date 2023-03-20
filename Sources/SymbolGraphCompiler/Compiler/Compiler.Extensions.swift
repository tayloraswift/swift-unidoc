extension Compiler
{
    struct Extensions
    {
        private
        var table:[SymbolExtensionIdentity<SymbolIdentifier>: Extension]

        init()
        {
            self.table = [:]
        }
    }
}
extension Compiler.Extensions
{
    func contains(_ type:SymbolIdentifier,
        where conditions:[GenericConstraint<SymbolIdentifier>]) -> Bool
    {
        self.table.keys.contains(.init(type, where: conditions))
    }

    subscript(type:SymbolIdentifier,
        where conditions:[GenericConstraint<SymbolIdentifier>]) -> Compiler.Extension
    {
        _read
        {
            yield  self.table[.init(type, where: conditions), default: .init()]
        }
        _modify
        {
            yield &self.table[.init(type, where: conditions), default: .init()]
        }
    }
}

