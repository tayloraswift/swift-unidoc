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
extension ConstraintReductionError:Diagnostic
{
    public
    typealias Symbolicator = DynamicSymbolicator

    @inlinable public static
    func += (output:inout DiagnosticOutput<DynamicSymbolicator>, self:Self)
    {
        output[.error] = """
        failed to reduce constraints: \
        \(self.constraints.map { "where \(output.symbolicator.constraints($0)))" })
        """
        output[.note] = """
        minimal constraints: \(output.symbolicator.constraints(self.minimal))
        """
    }
}
