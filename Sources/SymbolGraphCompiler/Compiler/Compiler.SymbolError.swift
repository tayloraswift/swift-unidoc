import SymbolGraphParts

extension Compiler
{
    public
    struct SymbolError:Equatable, Error, Sendable
    {
        public
        let usr:Symbol

        public
        init(invalid usr:Symbol)
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
