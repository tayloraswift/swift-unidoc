import Signatures
import SourceDiagnostics
import Symbols

extension SSGC {
    enum ConstraintReductionError: Error {
        case chimaeric(
            Set<GenericConstraint<Symbol.Decl>>,
            from: [Set<GenericConstraint<Symbol.Decl>>]
        )

        case redundant(
            Set<GenericConstraint<Symbol.Decl>>,
            from: [Set<GenericConstraint<Symbol.Decl>>]
        )
    }
}
