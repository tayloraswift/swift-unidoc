import Symbols

extension Compiler
{
    public
    enum UnexpectedSymbolError:Equatable, Error, Sendable
    {
        case file(uri:String)
        case block(Symbol.Block)
        case scalar(Symbol.Decl)
        case vector(Symbol.Decl.Vector)
    }
}
extension Compiler.UnexpectedSymbolError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .file(uri: let uri):
            return "Unexpected file symbol '\(uri)'. (Did you specify a repository root?)"
        case .block(let symbol):
            return "Unexpected block symbol '\(symbol)'."
        case .scalar(let symbol):
            return "Unexpected scalar symbol '\(symbol)'."
        case .vector(let symbol):
            return "Unexpected vector symbol '\(symbol)'."
        }
    }
}
