import Signatures
import Unidoc

@frozen public
struct ExtensionProjection:Equatable, Sendable
{
    public
    let conditions:[GenericConstraint<Unidoc.Scalar?>]
    public
    let culture:Unidoc.Scalar
    public
    let scope:Unidoc.Scalar

    public
    var conformances:[Unidoc.Scalar]
    public
    var features:[Unidoc.Scalar]
    public
    var nested:[Unidoc.Scalar]

    public
    var subforms:[Unidoc.Scalar]

    init(conditions:[GenericConstraint<Unidoc.Scalar?>],
        culture:Unidoc.Scalar,
        scope:Unidoc.Scalar,
        conformances:[Unidoc.Scalar] = [],
        features:[Unidoc.Scalar] = [],
        nested:[Unidoc.Scalar] = [],
        subforms:[Unidoc.Scalar] = [])
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
        conformances:[Unidoc.Scalar] = [],
        features:[Unidoc.Scalar] = [],
        nested:[Unidoc.Scalar] = [],
        subforms:[Unidoc.Scalar] = [])
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
