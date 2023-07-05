import SymbolGraphParts
import Unidoc

extension Compiler
{
    public
    enum SuperformError:Error, Sendable
    {
        case conflict(with:any SuperformRelationship.Type)
        case phylum(Unidoc.Decl)
    }
}
extension Compiler.SuperformError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .conflict(with: let type):
            return "Scalar already has superforms of type \(type)."
        case .phylum(let phylum):
            return "Scalar of phylum '\(phylum)' cannot be have superforms."
        }
    }
}
