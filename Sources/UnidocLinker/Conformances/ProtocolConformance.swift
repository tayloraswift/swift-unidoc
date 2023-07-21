import Signatures
import Unidoc

/// Conditions under which a type’s conformance to a protocol exists.
struct ProtocolConformance<Culture>
{
    let conditions:[GenericConstraint<Unidoc.Scalar?>]
    /// The module that declared the conformance.
    let culture:Culture

    init(conditions:[GenericConstraint<Unidoc.Scalar?>], culture:Culture)
    {
        self.conditions = conditions
        self.culture = culture
    }
}
extension ProtocolConformance:Equatable where Culture:Equatable
{
}
extension ProtocolConformance:Hashable where Culture:Hashable
{
}
extension ProtocolConformance:Sendable where Culture:Sendable
{
}
