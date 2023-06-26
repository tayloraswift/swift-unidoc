import Symbols

extension Compiler
{
    public
    enum OriginError:Equatable, Error, Sendable
    {
        case conflict(with:Symbol.Decl)
    }
}
extension Compiler.OriginError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .conflict(with: let symbol):
            return "Scalar already has source origin set to '\(symbol)'."
        }
    }
}
