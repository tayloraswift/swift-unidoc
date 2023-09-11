extension ServerTour.Stats
{
    @frozen public
    struct ByType
    {
        public
        var siteMap:Int
        public
        var restricted:Int
        public
        var query:Int
        public
        var other:Int

        @inlinable public
        init(siteMap:Int = 0,
            restricted:Int = 0,
            query:Int = 0,
            other:Int = 0)
        {
            self.siteMap = siteMap
            self.restricted = restricted
            self.query = query
            self.other = other
        }
    }
}
extension ServerTour.Stats.ByType
{
    /// The total count, except for the ``restricted`` type.
    @inlinable public
    var total:Int
    {
        self.siteMap + self.query + self.other
    }
}
extension ServerTour.Stats.ByType:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(Never, Int)...)
    {
        self.init(siteMap: 0)
    }
}
