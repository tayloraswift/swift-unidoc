extension Unidoc.Volume
{
    @frozen public
    struct Groups:Sendable
    {
        public
        var conformers:[Unidoc.ConformerGroup]
        public
        var extensions:[Unidoc.ExtensionGroup]
        public
        var polygons:[Unidoc.PolygonalGroup]
        public
        var topics:[Unidoc.TopicGroup]

        @inlinable public
        init(
            conformers:[Unidoc.ConformerGroup] = [],
            extensions:[Unidoc.ExtensionGroup] = [],
            polygons:[Unidoc.PolygonalGroup] = [],
            topics:[Unidoc.TopicGroup] = [])
        {
            self.conformers = conformers
            self.extensions = extensions
            self.polygons = polygons
            self.topics = topics
        }
    }
}
