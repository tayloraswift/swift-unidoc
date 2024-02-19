import Symbols

extension SSGC
{
    public
    enum DuplicateSymbolError:Equatable, Error, Sendable
    {
        case block(Symbol.Block)
        case scalar(Symbol.Decl)
    }
}
extension SSGC.DuplicateSymbolError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .block(let symbol):
            "Duplicate block symbol '\(symbol)'."
        case .scalar(let symbol):
            "Duplicate scalar symbol '\(symbol)'."
        }
    }
}
