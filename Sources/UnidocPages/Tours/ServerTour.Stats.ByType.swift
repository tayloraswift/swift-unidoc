extension ServerTour.Stats
{
    @frozen public
    struct ByType
    {
        public
        var siteMap:Int
        public
        var pipelineIndex:Int
        public
        var pipelineQuery:Int
        public
        var restricted:Int
        public
        var other:Int

        @inlinable public
        init(siteMap:Int = 0,
            pipelineIndex:Int = 0,
            pipelineQuery:Int = 0,
            restricted:Int = 0,
            other:Int = 0)
        {
            self.siteMap = siteMap
            self.pipelineIndex = pipelineIndex
            self.pipelineQuery = pipelineQuery
            self.restricted = restricted
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
        self.siteMap + self.pipelineIndex + self.pipelineQuery + self.other
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
