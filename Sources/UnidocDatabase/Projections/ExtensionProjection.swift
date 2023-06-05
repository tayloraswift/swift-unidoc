import Generics

@frozen public
struct ExtensionProjection:Equatable, Sendable
{
    public
    let conditions:[GenericConstraint<GlobalAddress?>]
    public
    let culture:GlobalAddress
    public
    let scope:GlobalAddress

    public
    var conformances:[GlobalAddress]
    public
    var features:[GlobalAddress]
    public
    var nested:[GlobalAddress]

    public
    var subforms:[GlobalAddress]

    init(conditions:[GenericConstraint<GlobalAddress?>],
        culture:GlobalAddress,
        scope:GlobalAddress,
        conformances:[GlobalAddress] = [],
        features:[GlobalAddress] = [],
        nested:[GlobalAddress] = [],
        subforms:[GlobalAddress] = [])
    {
        self.conditions = conditions
        self.culture = culture
        self.scope = scope

        self.conformances = conformances
        self.features = features
        self.nested = nested
        self.subforms = subforms
    }
}
