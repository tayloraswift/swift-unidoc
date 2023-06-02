extension Documentation
{
    @frozen public
    struct Files:Equatable, Sendable
    {
        public
        var symbols:SymbolTable<FileAddress>

        @inlinable internal
        init(symbols:SymbolTable<FileAddress> = .init())
        {
            self.symbols = symbols
        }
    }
}
