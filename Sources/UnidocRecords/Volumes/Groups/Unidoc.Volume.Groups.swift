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
        var intrinsics:[Unidoc.IntrinsicGroup]
        public
        var polygons:[Unidoc.PolygonalGroup]
        public
        var topics:[Unidoc.TopicGroup]

        @inlinable public
        init(
            conformers:[Unidoc.ConformerGroup] = [],
            extensions:[Unidoc.ExtensionGroup] = [],
            intrinsics:[Unidoc.IntrinsicGroup] = [],
            polygons:[Unidoc.PolygonalGroup] = [],
            topics:[Unidoc.TopicGroup] = [])
        {
            self.conformers = conformers
            self.extensions = extensions
            self.intrinsics = intrinsics
            self.polygons = polygons
            self.topics = topics
        }
    }
}
