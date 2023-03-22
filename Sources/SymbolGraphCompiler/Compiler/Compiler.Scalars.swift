extension Compiler
{
    struct Scalars
    {
        private
        var table:[ScalarSymbolResolution: Scalar]

        init()
        {
            self.table = [:]
        }
    }
}
extension Compiler.Scalars
{
    func contains(_ id:ScalarSymbolResolution) -> Bool
    {
        self.table.keys.contains(id)
    }

    subscript(id:ScalarSymbolResolution) -> Compiler.Scalar?
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

