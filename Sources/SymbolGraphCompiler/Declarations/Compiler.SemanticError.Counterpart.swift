import Symbols

extension Compiler.SemanticError
{
    public
    enum Counterpart:Equatable, Sendable
    {
        case origin(Symbol.Decl)
        case scope(Symbol)
    }
}
