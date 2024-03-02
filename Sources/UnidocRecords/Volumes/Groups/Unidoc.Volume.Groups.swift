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
        var curators:[Unidoc.CuratorGroup]
        public
        var topics:[Unidoc.TopicGroup]

        @inlinable public
        init(
            conformers:[Unidoc.ConformerGroup] = [],
            extensions:[Unidoc.ExtensionGroup] = [],
            intrinsics:[Unidoc.IntrinsicGroup] = [],
            curators:[Unidoc.CuratorGroup] = [],
            topics:[Unidoc.TopicGroup] = [])
        {
            self.conformers = conformers
            self.extensions = extensions
            self.intrinsics = intrinsics
            self.curators = curators
            self.topics = topics
        }
    }
}
