import Symbols

extension SSGC
{
    enum LexicalScopeError:Error, Sendable
    {
        case multiple(Symbol.Decl, Symbol.Decl)
    }
}
extension SSGC.LexicalScopeError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .multiple(let existing, let scope):
            """
            Scalar already has a lexical scope (\(existing)) and cannot have another (\(scope))
            """
        }
    }
}
