import Symbols

extension Compiler
{
    public
    enum DuplicateSymbolError:Equatable, Error, Sendable
    {
        case block(Symbol.Block)
        case scalar(Symbol.Decl)
    }
}
extension Compiler.DuplicateSymbolError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .block(let symbol):
            return "Duplicate block symbol '\(symbol)'."
        case .scalar(let symbol):
            return "Duplicate scalar symbol '\(symbol)'."
        }
    }
}
