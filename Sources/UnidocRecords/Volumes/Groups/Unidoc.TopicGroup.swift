import Unidoc

extension Unidoc
{
    /// This type of group is deprecated and should not be used anymore.
    ///
    /// It has been superseded by ``CuratorGroup``.
    @frozen public
    struct TopicGroup:Identifiable, Equatable, Sendable
    {
        public
        let id:Group

        public
        let culture:Scalar?
        public
        let scope:Scalar?

        public
        var overview:Passage?
        public
        var members:[TopicMember]

        @inlinable public
        init(id:Group,
            culture:Scalar? = nil,
            scope:Scalar? = nil,
            overview:Passage? = nil,
            members:[TopicMember] = [])
        {
            self.id = id

            self.culture = culture
            self.scope = scope

            self.overview = overview
            self.members = members
        }
    }
}
