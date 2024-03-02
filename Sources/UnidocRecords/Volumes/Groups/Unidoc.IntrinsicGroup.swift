extension Unidoc
{
    @frozen public
    struct IntrinsicGroup:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Group

        public
        let culture:Unidoc.Scalar
        public
        let scope:Unidoc.Scalar

        public
        var items:[Unidoc.Scalar]

        @inlinable public
        init(id:Unidoc.Group,
            culture:Unidoc.Scalar,
            scope:Unidoc.Scalar,
            items:[Unidoc.Scalar] = [])
        {
            self.id = id

            self.culture = culture
            self.scope = scope

            self.items = items
        }
    }
}
