import Signatures
import Unidoc

/// Describes a type’s conformance to a protocol.
struct ProtocolConformance<Culture>
{
    /// The conditions under which the conformance exists.
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
