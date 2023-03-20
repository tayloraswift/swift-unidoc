extension Compiler
{
    struct Scalars
    {
        private
        var table:[SymbolIdentifier: Scalar]

        init()
        {
            self.table = [:]
        }
    }
}
extension Compiler.Scalars
{
    func contains(_ id:SymbolIdentifier) -> Bool
    {
        self.table.keys.contains(id)
    }

    subscript(id:SymbolIdentifier) -> Compiler.Scalar?
    {
        _read
        {
            yield  self.table[id]
        }
        _modify
        {
            yield &self.table[id]
        }
    }
}

