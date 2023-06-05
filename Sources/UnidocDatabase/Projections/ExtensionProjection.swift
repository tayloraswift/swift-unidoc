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
extension ExtensionProjection
{
    var signature:GlobalSignature
    {
        .init(conditions: self.conditions, culture: self.culture, scope: self.scope)
    }

    init(signature:GlobalSignature,
        conformances:[GlobalAddress] = [],
        features:[GlobalAddress] = [],
        nested:[GlobalAddress] = [],
        subforms:[GlobalAddress] = [])
    {
        self.init(conditions: signature.conditions,
            culture: signature.culture,
            scope: signature.scope,
            conformances: conformances,
            features: features,
            nested: nested,
            subforms: subforms)
    }
}
extension ExtensionProjection
{
    /// Appends the contents of the other extension to this extension,
    /// ignoring the other extension’s signature. This function doesn’t
    /// remove duplicates.
    mutating
    func merge(with other:Self)
    {
        self.conformances += other.conformances
        self.features += other.features
        self.nested += other.nested
        self.subforms += other.subforms
    }
}
