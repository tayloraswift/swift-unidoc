import Symbols

extension SSGC
{
    public
    enum UndefinedSymbolError:Equatable, Error, Sendable
    {
        case block(Symbol.Block)
        case scalar(Symbol.Decl)
    }
}
extension SSGC.UndefinedSymbolError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .block(let symbol):
            "Undefined extension block symbol '\(symbol)'."
        case .scalar(let symbol):
            "Undefined (or external) scalar symbol '\(symbol)'."
        }
    }
}
