extension Unidoc
{
    @frozen public
    struct Versions:Sendable
    {
        public
        var list:[VersionState]
        public
        var top:TopOfTree?

        @inlinable public
        init(list:[VersionState] = [], top:TopOfTree? = nil)
        {
            self.list = list
            self.top = top
        }
    }
}
