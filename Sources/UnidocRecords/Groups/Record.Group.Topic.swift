import Unidoc

extension Record.Group
{
    @frozen public
    struct Topic:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        let culture:Unidoc.Scalar
        public
        let scope:Unidoc.Scalar

        /// Additional scalars to prefetch when this extension is loaded.
        /// This is used to obtain the masters for passage referents in the
        /// overview passages of the actual declarations in this extension
        /// without having to perform an additional lookup phase.
        public
        let prefetch:[Unidoc.Scalar]

        public
        var overview:Record.Passage?
        public
        var members:[Record.Link]

        @inlinable public
        init(id:Unidoc.Scalar,
            culture:Unidoc.Scalar,
            scope:Unidoc.Scalar,
            prefetch:[Unidoc.Scalar] = [],
            overview:Record.Passage? = nil,
            members:[Record.Link] = [])
        {
            self.id = id

            self.culture = culture
            self.scope = scope

            self.prefetch = prefetch

            self.overview = overview
            self.members = members
        }
    }
}
