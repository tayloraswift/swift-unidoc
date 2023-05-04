import SymbolGraphParts

extension Compiler
{
    public
    struct SymbolError:Equatable, Error, Sendable
    {
        public
        let usr:UnifiedSymbol

        public
        init(invalid usr:UnifiedSymbol)
        {
            self.usr = usr
        }
    }
}
extension Compiler.SymbolError:CustomStringConvertible
{
    public
    var description:String
    {
        return "Invalid symbol resolution '\(self.usr)'."
    }
}
