import Symbols

extension SSGC.Overload
{
    @frozen public
    enum Target:Sendable
    {
        case module(Symbol.Module)
        case decl(Symbol.Decl, self:Symbol.Decl? = nil)
    }
}
