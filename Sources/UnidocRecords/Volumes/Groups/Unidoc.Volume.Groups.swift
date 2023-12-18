extension Unidoc.Volume
{
    @frozen public
    struct Groups:Sendable
    {
        public
        var extensions:[Unidoc.Group.Extension]
        public
        var polygons:[Unidoc.Group.Polygon]
        public
        var topics:[Unidoc.Group.Topic]

        @inlinable public
        init(
            extensions:[Unidoc.Group.Extension] = [],
            polygons:[Unidoc.Group.Polygon] = [],
            topics:[Unidoc.Group.Topic] = [])
        {
            self.extensions = extensions
            self.polygons = polygons
            self.topics = topics
        }
    }
}
