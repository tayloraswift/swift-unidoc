extension ServerProfile
{
    @frozen public
    struct ByType
    {
        public
        var siteMap:Int
        public
        var query:Int
        public
        var other:Int

        @inlinable public
        init(siteMap:Int = 0,
            query:Int = 0,
            other:Int = 0)
        {
            self.siteMap = siteMap
            self.query = query
            self.other = other
        }
    }
}
extension ServerProfile.ByType
{
    /// The total count.
    @inlinable public
    var total:Int
    {
        self.siteMap + self.query + self.other
    }
}
extension ServerProfile.ByType:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(Never, Int)...)
    {
        self.init(siteMap: 0)
    }
}
