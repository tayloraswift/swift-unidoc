import Unidoc

extension Record.Group
{
    @frozen public
    struct Automatic:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar
        public
        var scope:Unidoc.Scalar?
        public
        var members:[Unidoc.Scalar]

        @inlinable public
        init(id:Unidoc.Scalar,
            scope:Unidoc.Scalar? = nil,
            members:[Unidoc.Scalar] = [])
        {
            self.id = id
            self.scope = scope
            self.members = members
        }
    }
}
