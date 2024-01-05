import Unidoc

extension Unidoc
{
    @frozen public
    struct TopicGroup:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Group.ID

        public
        let culture:Unidoc.Scalar?
        public
        let scope:Unidoc.Scalar?

        /// Additional scalars to prefetch when this extension is loaded.
        /// This is used to obtain the masters for passage referents in the
        /// overview passages of the actual declarations in this extension
        /// without having to perform an additional lookup phase.
        public
        let prefetch:[Unidoc.Scalar]

        public
        var overview:Unidoc.Passage?
        public
        var members:[Unidoc.VertexLink]

        @inlinable public
        init(id:Unidoc.Group.ID,
            culture:Unidoc.Scalar? = nil,
            scope:Unidoc.Scalar? = nil,
            prefetch:[Unidoc.Scalar] = [],
            overview:Unidoc.Passage? = nil,
            members:[Unidoc.VertexLink] = [])
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
