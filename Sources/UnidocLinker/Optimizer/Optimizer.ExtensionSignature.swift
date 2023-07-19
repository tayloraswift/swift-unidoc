import Signatures
import Unidoc

extension Optimizer
{
    struct ExtensionSignature:Equatable, Hashable, Sendable
    {
        let conditions:[GenericConstraint<Unidoc.Scalar?>]
        let extends:Unidoc.Scalar

        init(conditions:[GenericConstraint<Unidoc.Scalar?>],
            extends:Unidoc.Scalar)
        {
            self.conditions = conditions
            self.extends = extends
        }
    }
}
