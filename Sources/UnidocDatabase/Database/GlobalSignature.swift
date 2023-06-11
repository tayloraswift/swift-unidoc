import Generics
import SymbolGraphs

struct GlobalSignature:Equatable, Hashable, Sendable
{
    let conditions:[GenericConstraint<GlobalAddress?>]
    let culture:GlobalAddress
    let scope:GlobalAddress

    init(conditions:[GenericConstraint<GlobalAddress?>],
        culture:GlobalAddress,
        scope:GlobalAddress)
    {
        self.conditions = conditions
        self.culture = culture
        self.scope = scope
    }
}
