import Symbols
import SymbolGraphParts
import TraceableErrors

extension Compiler
{
    public
    struct VertexError:Error, Sendable
    {
        public
        let underlying:any Error
        public
        let symbol:UnifiedSymbol
        public
        let phylum:UnifiedPhylum

        public
        init(underlying:any Error, symbol:UnifiedSymbol, phylum:UnifiedPhylum)
        {
            self.underlying = underlying
            self.symbol = symbol
            self.phylum = phylum
        }
    }
}
extension Compiler.VertexError
{
    init(underlying:any Error, in description:SymbolDescription)
    {
        self.init(underlying: underlying, symbol: description.usr, phylum: description.phylum)
    }
}
extension Compiler.VertexError:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.symbol == rhs.symbol && lhs.underlying == rhs.underlying
    }
}
extension Compiler.VertexError:TraceableError
{
    public
    var notes:[String]
    {
        ["While validating symbol \(self.symbol) of phylum '\(self.phylum)'"]
    }
}
