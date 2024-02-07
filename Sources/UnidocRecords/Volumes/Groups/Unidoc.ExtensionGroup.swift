import Signatures
import Unidoc

extension Unidoc
{
    /// Models an extension, which is characterized by a set of constraints, a perpetrating
    /// culture, and an extended declaration.
    ///
    /// Extension groups are *groups* in the sense that they represent multiple merged
    /// extension blocks, but the name of the type was chosen because they can also be used to
    /// group related vertices, and for symmetry with the other group types.
    @frozen public
    struct ExtensionGroup:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Group

        public
        let constraints:[GenericConstraint<Unidoc.Scalar?>]
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

        public
        var overview:Unidoc.Passage?
        public
        var details:Unidoc.Passage?

        @inlinable public
        init(id:Unidoc.Group,
            constraints:[GenericConstraint<Unidoc.Scalar?>],
            culture:Unidoc.Scalar,
            scope:Unidoc.Scalar,
            conformances:[Unidoc.Scalar] = [],
            features:[Unidoc.Scalar] = [],
            nested:[Unidoc.Scalar] = [],
            subforms:[Unidoc.Scalar] = [],
            overview:Unidoc.Passage? = nil,
            details:Unidoc.Passage? = nil)
        {
            self.id = id

            self.constraints = constraints
            self.culture = culture
            self.scope = scope

            self.conformances = conformances
            self.features = features
            self.nested = nested
            self.subforms = subforms

            self.overview = overview
            self.details = details
        }
    }
}
extension Unidoc.ExtensionGroup
{
    /// Returns true if and only if this extension contains no conformances, features, nested
    /// declarations, subforms, or written documentation. The extension constraints are ignored.
    @inlinable public
    var isEmpty:Bool
    {
        self.conformances.isEmpty &&
        self.features.isEmpty &&
        self.nested.isEmpty &&
        self.subforms.isEmpty &&
        self.overview == nil &&
        self.details == nil
    }

    public consuming
    func subtracting(_ members:Set<Unidoc.Scalar>) -> Self
    {
        self.conformances.removeAll(where: members.contains(_:))
        self.features.removeAll(where: members.contains(_:))
        self.nested.removeAll(where: members.contains(_:))
        self.subforms.removeAll(where: members.contains(_:))

        return self
    }
}
