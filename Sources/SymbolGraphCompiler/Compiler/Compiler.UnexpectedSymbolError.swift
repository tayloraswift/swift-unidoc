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
            "Unexpected file symbol '\(uri)'. (Did you specify a repository root?)"
        case .block(let symbol):
            "Unexpected block symbol '\(symbol)'."
        case .scalar(let symbol):
            "Unexpected scalar symbol '\(symbol)'."
        case .vector(let symbol):
            "Unexpected vector symbol '\(symbol)'."
        }
    }
}
