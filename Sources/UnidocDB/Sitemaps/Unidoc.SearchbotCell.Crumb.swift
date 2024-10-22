import UnixTime

extension Unidoc.SearchbotCell
{
    @frozen public
    struct Crumb:Sendable
    {
        public
        var fetched:UnixMillisecond?
        public
        var fetches:Int32?

        @inlinable public
        init(fetched:UnixMillisecond?, fetches:Int32?)
        {
            self.fetched = fetched
            self.fetches = fetches
        }
    }
}
