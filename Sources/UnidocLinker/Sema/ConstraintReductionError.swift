import Signatures
import Unidoc
import SourceDiagnostics

struct ConstraintReductionError:Error, Equatable, Sendable
{
    let constraints:[[GenericConstraint<Unidoc.Scalar?>]]
    let minimal:[GenericConstraint<Unidoc.Scalar?>]
    let subject:Unidoc.Scalar
    let `protocol`:Unidoc.Scalar

    init(invalid constraints:[[GenericConstraint<Unidoc.Scalar?>]],
        minimal:[GenericConstraint<Unidoc.Scalar?>],
        subject:Unidoc.Scalar,
        `protocol`:Unidoc.Scalar)
    {
        self.constraints = constraints
        self.minimal = minimal
        self.subject = subject
        self.protocol = `protocol`
    }
}
extension ConstraintReductionError:Diagnostic
{
    typealias Symbolicator = Unidoc.Symbolicator

    static
    func += (output:inout DiagnosticOutput<Unidoc.Symbolicator>, self:Self)
    {
        output[.error] = """
        failed to reduce constraints: \
        \(self.constraints.map { "where \(output.symbolicator.constraints($0))" })
        """
        output[.note] = """
        minimal constraints: \(output.symbolicator.constraints(self.minimal))
        """
        output[.note] = """
        in conformance of \
        \(output.symbolicator[self.subject]) to \
        \(output.symbolicator[self.protocol])
        """
    }
}
