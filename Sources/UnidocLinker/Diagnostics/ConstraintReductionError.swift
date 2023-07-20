import Signatures
import Unidoc
import UnidocDiagnostics

@frozen public
struct ConstraintReductionError:Error, Equatable, Sendable
{
    public
    let constraints:[[GenericConstraint<Unidoc.Scalar?>]]
    public
    let minimal:[GenericConstraint<Unidoc.Scalar?>]

    @inlinable public
    init(invalid constraints:[[GenericConstraint<Unidoc.Scalar?>]],
        minimal:[GenericConstraint<Unidoc.Scalar?>])
    {
        self.constraints = constraints
        self.minimal = minimal
    }
}
extension ConstraintReductionError:DynamicLinkerError
{
    public
    func symbolicated(with symbolicator:DynamicSymbolicator) -> [Diagnostic]
    {
        [
            .init(.error, context: .init(),
                message: """
                Failed to reduce constraints: \
                \(self.constraints.map { "where \(symbolicator.constraints($0)))" })
                """),
            .init(.note, context: .init(),
                message: """
                Minimal constraints: \(symbolicator.constraints(self.minimal))
                """)
        ]
    }
}
