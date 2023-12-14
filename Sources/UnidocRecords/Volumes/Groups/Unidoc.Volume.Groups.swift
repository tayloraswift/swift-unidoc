extension Unidoc.Volume
{
    @frozen public
    struct Groups:Sendable
    {
        public
        var autogroups:[Unidoc.Group.Automatic]
        public
        var extensions:[Unidoc.Group.Extension]
        public
        var topics:[Unidoc.Group.Topic]

        @inlinable public
        init(
            autogroups:[Unidoc.Group.Automatic] = [],
            extensions:[Unidoc.Group.Extension] = [],
            topics:[Unidoc.Group.Topic] = [])
        {
            self.autogroups = autogroups
            self.extensions = extensions
            self.topics = topics
        }
    }
}
