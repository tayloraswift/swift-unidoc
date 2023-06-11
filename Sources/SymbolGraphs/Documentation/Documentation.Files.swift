import Symbols

extension Documentation
{
    @frozen public
    struct Files:Equatable, Sendable
    {
        public
        var symbols:SymbolTable<FileAddress, FileSymbol>

        @inlinable internal
        init(symbols:SymbolTable<FileAddress, FileSymbol> = .init())
        {
            self.symbols = symbols
        }
    }
}
