import Symbols

extension SSGC {
    public enum SemanticError: Error, Sendable {
        case cannot(have: Counterparts, as: Phylum.Decl)
    }
}
extension SSGC.SemanticError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .cannot(have: .requirements, as: let phylum):
            "Scalar of phylum '\(phylum)' cannot have requirements"

        case .cannot(have: .inhabitants, as: let phylum):
            "Scalar of phylum '\(phylum)' cannot have enumeration cases"

        case .cannot(have: .scope, as: let phylum):
            "Scalar of phylum '\(phylum)' cannot have a lexical scope"

        case .cannot(have: .superforms(besides: nil), as: let phylum):
            "Scalar of phylum '\(phylum)' cannot have superforms"

        case .cannot(have: .superforms(besides: let type?), as: _):
            "Scalar already has superforms of type \(type)"
        }
    }
}
