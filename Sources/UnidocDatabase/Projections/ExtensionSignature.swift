import Signatures
import Unidoc

struct ExtensionSignature:Equatable, Hashable, Sendable
{
    let conditions:[GenericConstraint<Unidoc.Scalar?>]
    let culture:Unidoc.Scalar
    let scope:Unidoc.Scalar

    init(conditions:[GenericConstraint<Unidoc.Scalar?>],
        culture:Unidoc.Scalar,
        scope:Unidoc.Scalar)
    {
        self.conditions = conditions
        self.culture = culture
        self.scope = scope
    }
}
