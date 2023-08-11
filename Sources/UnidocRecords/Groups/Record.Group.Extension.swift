import Signatures
import Unidoc

extension Record.Group
{
    @frozen public
    struct Extension:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        let conditions:[GenericConstraint<Unidoc.Scalar?>]
        public
        let culture:Unidoc.Scalar
        public
        let scope:Unidoc.Scalar

        public
        let requirements:[Unidoc.Scalar]
        public
        let conformances:[Unidoc.Scalar]
        public
        let features:[Unidoc.Scalar]
        public
        let nested:[Unidoc.Scalar]
        public
        let subforms:[Unidoc.Scalar]

        /// Additional scalars to prefetch when this extension is loaded.
        /// This is used to obtain the masters for passage referents in the
        /// overview passages of the actual declarations in this extension
        /// without having to perform an additional lookup phase.
        public
        let prefetch:[Unidoc.Scalar]

        public
        var overview:Record.Passage?
        public
        var details:Record.Passage?

        @inlinable public
        init(id:Unidoc.Scalar,
            conditions:[GenericConstraint<Unidoc.Scalar?>],
            culture:Unidoc.Scalar,
            scope:Unidoc.Scalar,
            requirements:[Unidoc.Scalar] = [],
            conformances:[Unidoc.Scalar] = [],
            features:[Unidoc.Scalar] = [],
            nested:[Unidoc.Scalar] = [],
            subforms:[Unidoc.Scalar] = [],
            prefetch:[Unidoc.Scalar] = [],
            overview:Record.Passage? = nil,
            details:Record.Passage? = nil)
        {
            self.id = id

            self.conditions = conditions
            self.culture = culture
            self.scope = scope

            self.requirements = requirements
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
