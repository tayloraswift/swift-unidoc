import Symbols

extension SSGC.SemanticError
{
    public
    enum Counterpart:Equatable, Sendable
    {
        case origin(Symbol.Decl)
        case scope(Symbol.USR)
    }
}
