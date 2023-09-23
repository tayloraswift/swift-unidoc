extension ServerResource
{
    @frozen public
    struct Headers:Equatable, Hashable, Sendable
    {
        public
        var canonical:String?

        @inlinable public
        init(canonical:String? = nil)
        {
            self.canonical = canonical
        }
    }
}
