import Generics
import SymbolGraphs

/// A type suitable for identifying an extension within a single documentation object.
struct LocalSignature:Hashable, Equatable, Sendable
{
    let conditions:[GenericConstraint<ScalarAddress>]
    let culture:Int
    let scope:ScalarAddress

    init(conditions:[GenericConstraint<ScalarAddress>], culture:Int, scope:ScalarAddress)
    {
        self.conditions = conditions
        self.culture = culture
        self.scope = scope
    }
}
extension LocalSignature
{
    init(extension:__shared SymbolGraph.Extension, of scope:ScalarAddress)
    {
        self.init(conditions: `extension`.conditions,
            culture: `extension`.culture,
            scope: scope)
    }
}
