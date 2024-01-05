import Signatures
import Unidoc

extension Unidoc
{
    @frozen public
    struct ExtensionGroup:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Group.ID

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

        /// Additional scalars to prefetch when this extension is loaded.
        /// This is used to obtain the masters for passage referents in the
        /// overview passages of the actual declarations in this extension
        /// without having to perform an additional lookup phase.
        public
        var prefetch:[Unidoc.Scalar]

        public
        var overview:Unidoc.Passage?
        public
        var details:Unidoc.Passage?

        @inlinable public
        init(id:Unidoc.Group.ID,
            constraints:[GenericConstraint<Unidoc.Scalar?>],
            culture:Unidoc.Scalar,
            scope:Unidoc.Scalar,
            conformances:[Unidoc.Scalar] = [],
            features:[Unidoc.Scalar] = [],
            nested:[Unidoc.Scalar] = [],
            subforms:[Unidoc.Scalar] = [],
            prefetch:[Unidoc.Scalar] = [],
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

            self.prefetch = prefetch

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
