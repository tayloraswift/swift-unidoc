import Signatures
import Unidoc

extension DynamicLinker
{
    struct ExtensionSignature:Equatable, Hashable, Sendable
    {
        let conditions:[GenericConstraint<Unidoc.Scalar?>]
        let culture:Unidoc.Scalar
        let extends:Unidoc.Scalar

        init(conditions:[GenericConstraint<Unidoc.Scalar?>],
            culture:Unidoc.Scalar,
            extends:Unidoc.Scalar)
        {
            self.conditions = conditions
            self.culture = culture
            self.extends = extends
        }
    }
}
extension DynamicLinker.ExtensionSignature
{
    var global:Optimizer.ExtensionSignature
    {
        .init(conditions: self.conditions, extends: self.extends)
    }
}
