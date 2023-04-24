import TraceableErrors

extension Compiler
{
    public
    struct VertexError:Error, Sendable
    {
        public
        let underlying:any Error
        public
        let symbol:Symbol

        public
        init(underlying:any Error, in symbol:Symbol)
        {
            self.underlying = underlying
            self.symbol = symbol
        }
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
        ["While validating symbol \(self.symbol)"]
    }
}
