extension Volume
{
    @frozen public
    struct Groups:Sendable
    {
        public
        var autogroups:[Group.Automatic]
        public
        var extensions:[Group.Extension]
        public
        var topics:[Group.Topic]

        @inlinable public
        init(
            autogroups:[Group.Automatic] = [],
            extensions:[Group.Extension] = [],
            topics:[Group.Topic] = [])
        {
            self.autogroups = autogroups
            self.extensions = extensions
            self.topics = topics
        }
    }
}
