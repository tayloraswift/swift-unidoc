import Symbols

extension Compiler
{
    public
    enum SemanticError:Error, Sendable
    {
        case already(has:Counterpart)
        case cannot(have:Counterparts, as:Phylum.Decl)
    }
}
extension Compiler.SemanticError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .already(has: .origin(let symbol)):
            return "Scalar already has an origin, \(symbol)."

        case .already(has: .scope(let symbol)):
            return "Scalar already has a lexical scope, \(symbol)."

        case .cannot(have: .requirements, as: let phylum):
            return "Scalar of phylum '\(phylum)' cannot have requirements."

        case .cannot(have: .scope, as: let phylum):
            return "Scalar of phylum '\(phylum)' cannot have a lexical scope."

        case .cannot(have: .superforms(besides: nil), as: let phylum):
            return "Scalar of phylum '\(phylum)' cannot have superforms."

        case .cannot(have: .superforms(besides: let type?), as: _):
            return "Scalar already has superforms of type \(type)."
        }
    }
}
