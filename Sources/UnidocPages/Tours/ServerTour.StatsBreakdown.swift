import HTML

extension ServerTour
{
    struct StatsBreakdown
    {
        private
        var responses:Pie<Stat>
        private
        var requests:Pie<Stat>
        private
        var bytes:Pie<Stat>

        private
        init(responses:Pie<Stat> = [], requests:Pie<Stat> = [], bytes:Pie<Stat> = [])
        {
            self.responses = responses
            self.requests = requests
            self.bytes = bytes
        }
    }
}
extension ServerTour.StatsBreakdown
{
    init(_ stats:ServerTour.Stats)
    {
        self.init()

        func style(_ prose:String) -> String
        {
            prose.lowercased().split(whereSeparator: \.isWhitespace).joined(separator: "-")
        }

        for (state, value):(String, Int) in
        [
            ("Multiple Choices",        stats.responses.multipleChoices),
            ("Not Modified",            stats.responses.notModified),
            ("OK",                      stats.responses.ok),
            ("Redirected Permanently",  stats.responses.redirectedPermanently),
            ("Redirected Temporarily",  stats.responses.redirectedTemporarily),
            ("Not Found",               stats.responses.notFound),
            ("Errored",                 stats.responses.errored),
            ("Unauthorized",            stats.responses.unauthorized),
        ]
        {
            if  value > 0
            {
                self.responses.append(.init(
                    stratum: "responses",
                    state: state,
                    value: value,
                    class: style(state)))
            }
        }

        for (state, value):(String, Int) in
        [
            ("for site map requests",   stats.requests.siteMap),
            ("for database queries",    stats.requests.query),
            ("for other queries",       stats.requests.other),
        ]
        {
            if  value > 0
            {
                self.requests.append(.init(
                    stratum: "requests",
                    state: state,
                    value: value,
                    class: style(state)))
            }
        }

        for (state, value):(String, Int) in
        [
            ("for site map requests",   stats.bytes.siteMap),
            ("for database queries",    stats.bytes.query),
            ("for other queries",       stats.bytes.other),
        ]
        {
            if  value > 0
            {
                self.bytes.append(.init(
                    stratum: "bytes",
                    state: state,
                    value: value,
                    class: style(state)))
            }
        }
    }
}
extension ServerTour.StatsBreakdown:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.h3] = "Responses"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.responses
            $0[.figcaption] { $0[.dl] = self.responses.legend }
        }

        html[.h3] = "Requests"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.requests
            $0[.figcaption] { $0[.dl] = self.requests.legend }
        }

        html[.h3] = "Data Transfer"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.bytes
            $0[.figcaption] { $0[.dl] = self.bytes.legend }
        }
    }
}
