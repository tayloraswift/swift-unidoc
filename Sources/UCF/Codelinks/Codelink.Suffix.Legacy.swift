import FNV1

extension Codelink.Suffix
{
    @frozen public
    struct Legacy:Equatable, Hashable, Sendable
    {
        public
        let filter:Filter
        public
        let hash:FNV24?

        @inlinable public
        init(filter:Filter, hash:FNV24? = nil)
        {
            self.filter = filter
            self.hash = hash
        }
    }
}
