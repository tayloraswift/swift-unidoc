import Generics
import SymbolGraphs

@frozen public
struct ExtensionProjection:Equatable, Sendable
{
    public
    let conditions:[GenericConstraint<Scalar96?>]
    public
    let culture:Scalar96
    public
    let scope:Scalar96

    public
    var conformances:[Scalar96]
    public
    var features:[Scalar96]
    public
    var nested:[Scalar96]

    public
    var subforms:[Scalar96]

    init(conditions:[GenericConstraint<Scalar96?>],
        culture:Scalar96,
        scope:Scalar96,
        conformances:[Scalar96] = [],
        features:[Scalar96] = [],
        nested:[Scalar96] = [],
        subforms:[Scalar96] = [])
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
    var signature:ExtensionSignature
    {
        .init(conditions: self.conditions, culture: self.culture, scope: self.scope)
    }

    init(signature:ExtensionSignature,
        conformances:[Scalar96] = [],
        features:[Scalar96] = [],
        nested:[Scalar96] = [],
        subforms:[Scalar96] = [])
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
