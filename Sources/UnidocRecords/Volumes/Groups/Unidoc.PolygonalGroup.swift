import Unidoc

extension Unidoc
{
    @frozen public
    struct PolygonalGroup:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Group.ID
        public
        var scope:Unidoc.Scalar?
        public
        var members:[Unidoc.Scalar]

        @inlinable public
        init(id:Unidoc.Group.ID,
            scope:Unidoc.Scalar? = nil,
            members:[Unidoc.Scalar] = [])
        {
            self.id = id
            self.scope = scope
            self.members = members
        }
    }
}
