extension ServerProfile
{
    @frozen public
    struct ByStatus
    {
        public
        var ok:Int
        public
        var notModified:Int
        public
        var multipleChoices:Int
        public
        var redirectedPermanently:Int
        public
        var redirectedTemporarily:Int
        public
        var notFound:Int
        public
        var gone:Int
        public
        var errored:Int
        public
        var unauthorized:Int

        @inlinable public
        init(ok:Int = 0,
            notModified:Int = 0,
            multipleChoices:Int = 0,
            redirectedPermanently:Int = 0,
            redirectedTemporarily:Int = 0,
            notFound:Int = 0,
            gone:Int = 0,
            errored:Int = 0,
            unauthorized:Int = 0)
        {
            self.ok = ok
            self.notModified = notModified
            self.multipleChoices = multipleChoices
            self.redirectedPermanently = redirectedPermanently
            self.redirectedTemporarily = redirectedTemporarily
            self.notFound = notFound
            self.gone = gone
            self.errored = errored
            self.unauthorized = unauthorized
        }
    }
}
extension ServerProfile.ByStatus:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(Never, Int)...)
    {
        self.init(ok: 0)
    }
}
extension ServerProfile.ByStatus:PieValues
{
    @inlinable public
    var sectors:KeyValuePairs<SectorKey, Int>
    {
        [
            .ok:                    self.ok,
            .notModified:           self.notModified,
            .redirectedPermanently: self.redirectedPermanently,
            .redirectedTemporarily: self.redirectedTemporarily,
            .notFound:              self.notFound,
            .gone:                  self.gone,
            .errored:               self.errored,
            .unauthorized:          self.unauthorized,
            .multipleChoices:       self.multipleChoices,
        ]
    }
}
