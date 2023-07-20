import Signatures
import Unidoc

extension Optimizer
{
    /// Conditions under which a type’s conformance to a protocol exists.
    /// This signature is a valid identity within a single type across
    /// multiple cultures.
    struct ConformanceSignature:Equatable, Hashable, Sendable
    {
        let conditions:[GenericConstraint<Unidoc.Scalar?>]
        let culture:Unidoc.Scalar

        init(conditions:[GenericConstraint<Unidoc.Scalar?>],
            culture:Unidoc.Scalar)
        {
            self.conditions = conditions
            self.culture = culture
        }
    }
}
