import Generics
import SymbolGraphs

struct ExtensionSignature:Equatable, Hashable, Sendable
{
    let conditions:[GenericConstraint<Scalar96?>]
    let culture:Scalar96
    let scope:Scalar96

    init(conditions:[GenericConstraint<Scalar96?>], culture:Scalar96, scope:Scalar96)
    {
        self.conditions = conditions
        self.culture = culture
        self.scope = scope
    }
}
