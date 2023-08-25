import Signatures
import Unidoc

extension DynamicLinker
{
    struct ExtensionSignature:Equatable, Hashable, Sendable
    {
        let conditions:[GenericConstraint<Unidoc.Scalar?>]
        let culture:Int
        let extends:Unidoc.Scalar

        init(conditions:[GenericConstraint<Unidoc.Scalar?>],
            culture:Int,
            extends:Unidoc.Scalar)
        {
            self.conditions = conditions
            self.culture = culture
            self.extends = extends
        }
    }
}
