extension Unidoc
{
    @frozen public
    struct Versions:Sendable
    {
        public
        var prereleases:[Tag]
        public
        var releases:[Tag]
        public
        var top:TopOfTree?

        @inlinable public
        init(prereleases:[Tag] = [],
            releases:[Tag] = [],
            top:TopOfTree? = nil)
        {
            self.prereleases = prereleases
            self.releases = releases
            self.top = top
        }
    }
}
