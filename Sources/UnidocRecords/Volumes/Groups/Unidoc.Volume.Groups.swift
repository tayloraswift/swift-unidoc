extension Unidoc.Volume
{
    @frozen public
    struct Groups:Sendable
    {
        public
        var extensions:[Unidoc.ExtensionGroup]
        public
        var polygons:[Unidoc.PolygonalGroup]
        public
        var topics:[Unidoc.TopicGroup]

        @inlinable public
        init(
            extensions:[Unidoc.ExtensionGroup] = [],
            polygons:[Unidoc.PolygonalGroup] = [],
            topics:[Unidoc.TopicGroup] = [])
        {
            self.extensions = extensions
            self.polygons = polygons
            self.topics = topics
        }
    }
}
