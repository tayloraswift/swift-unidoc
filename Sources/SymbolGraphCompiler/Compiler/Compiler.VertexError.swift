import Symbols
import SymbolGraphParts
import TraceableErrors
import Unidoc

extension Compiler
{
    public
    struct VertexError:Error, Sendable
    {
        public
        let underlying:any Error
        public
        let symbol:Symbol.USR
        public
        let phylum:Phylum

        public
        init(underlying:any Error, symbol:Symbol.USR, phylum:Phylum)
        {
            self.underlying = underlying
            self.symbol = symbol
            self.phylum = phylum
        }
    }
}
extension Compiler.VertexError
{
    init(underlying:any Error, in description:SymbolGraphPart.Vertex)
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
