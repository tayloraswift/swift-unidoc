import Unidoc

extension Unidoc
{
    @frozen public
    struct TopicGroup:Identifiable, Equatable, Sendable
    {
        public
        let id:Group

        public
        let culture:Scalar?
        public
        let scope:Scalar?

        /// Additional scalars to prefetch when this extension is loaded.
        /// This is used to obtain the masters for passage referents in the
        /// overview passages of the actual declarations in this extension
        /// without having to perform an additional lookup phase.
        public
        let prefetch:[Scalar]

        public
        var overview:Passage?
        public
        var members:[TopicMember]

        @inlinable public
        init(id:Group,
            culture:Scalar? = nil,
            scope:Scalar? = nil,
            prefetch:[Scalar] = [],
            overview:Passage? = nil,
            members:[TopicMember] = [])
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
