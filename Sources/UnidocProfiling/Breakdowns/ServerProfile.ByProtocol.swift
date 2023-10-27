extension ServerProfile
{
    @frozen public
    struct ByProtocol
    {
        public
        var http1:Int

        public
        var http2:Int

        @inlinable public
        init(http1:Int = 0, http2:Int = 0)
        {
            self.http1 = http1
            self.http2 = http2
        }
    }
}
extension ServerProfile.ByProtocol:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(Never, Int)...)
    {
        self.init(http1: 0)
    }
}
extension ServerProfile.ByProtocol
{
    func chart(stratum:String) -> Pie<Stat>
    {
        var chart:Pie<Stat> = []

        for (value, name, style):(Int, String, String) in
        [
            (
                self.http1,
                "HTTP/1.1",
                "http1"
            ),
            (
                self.http2,
                "HTTP/2",
                "http2"
            ),
        ]
        {
            if  value > 0
            {
                chart.append(.init(name,
                    stratum: stratum,
                    value: value,
                    class: "protocol \(style)"))
            }
        }

        return chart
    }
}
