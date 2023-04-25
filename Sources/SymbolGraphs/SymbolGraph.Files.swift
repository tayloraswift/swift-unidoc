extension SymbolGraph
{
    @frozen public
    struct Files:Sendable
    {
        public
        var symbols:SymbolTable<FileAddress>

        init()
        {
            self.symbols = .init()
        }
    }
}
