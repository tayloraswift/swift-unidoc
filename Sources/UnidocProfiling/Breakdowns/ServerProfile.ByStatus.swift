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
extension ServerProfile.ByStatus
{
    func chart(stratum:String) -> Pie<Stat>
    {
        var chart:Pie<Stat> = []

        for (value, name, style):(Int, String, String) in
        [
            (
                self.multipleChoices,
                "Multiple Choices",
                "multiple-choices"
            ),
            (
                self.notModified,
                "Not Modified",
                "not-modified"
            ),
            (
                self.ok,
                "OK",
                "ok"
            ),
            (
                self.redirectedPermanently,
                "Redirected Permanently",
                "redirected-permanently"
            ),
            (
                self.redirectedTemporarily,
                "Redirected Temporarily",
                "redirected-temporarily"
            ),
            (
                self.notFound,
                "Not Found",
                "not-found"
            ),
            (
                self.gone,
                "Gone",
                "gone"
            ),
            (
                self.errored,
                "Errored",
                "errored"
            ),
            (
                self.unauthorized,
                "Unauthorized",
                "unauthorized"
            ),
        ]
        {
            if  value > 0
            {
                chart.append(.init(name,
                    stratum: stratum,
                    value: value,
                    class: "status \(style)"))
            }
        }

        return chart
    }
}
