import Unidoc

extension Unidoc
{
    /// A curator group is the simplest type of group there is. It has no culture, and if it
    /// lacks a ``scope``, then it can only be loaded by direct ``id`` reference.
    @frozen public
    struct CuratorGroup:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Group
        public
        var scope:Unidoc.Scalar?
        public
        var items:[Unidoc.Scalar]

        @inlinable public
        init(id:Unidoc.Group,
            scope:Unidoc.Scalar? = nil,
            items:[Unidoc.Scalar] = [])
        {
            self.id = id
            self.scope = scope
            self.items = items
        }
    }
}
