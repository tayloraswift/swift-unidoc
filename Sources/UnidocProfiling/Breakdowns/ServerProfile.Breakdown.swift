import HTML

extension ServerProfile
{
    @frozen public
    struct Breakdown
    {
        private
        var languages:Pie<ByLanguage.Stat>
        private
        var responses:
        (
            toBarbie:Pie<ByStatus.Stat>,
            toBratz:Pie<ByStatus.Stat>,
            toGooglebot:Pie<ByStatus.Stat>,
            toBingbot:Pie<ByStatus.Stat>,
            toOtherSearch:Pie<ByStatus.Stat>,
            toOtherRobots:Pie<ByStatus.Stat>
        )
        private
        var requests:
        (
            http2:Pie<ByClient.Stat>,
            http1:Pie<ByClient.Stat>,
            bytes:Pie<ByClient.Stat>
        )

        private
        init(
            languages:Pie<ByLanguage.Stat>,
            responses:
            (
                toBarbie:Pie<ByStatus.Stat>,
                toBratz:Pie<ByStatus.Stat>,
                toGooglebot:Pie<ByStatus.Stat>,
                toBingbot:Pie<ByStatus.Stat>,
                toOtherSearch:Pie<ByStatus.Stat>,
                toOtherRobots:Pie<ByStatus.Stat>
            ),
            requests:
            (
                http2:Pie<ByClient.Stat>,
                http1:Pie<ByClient.Stat>,
                bytes:Pie<ByClient.Stat>
            ))
        {
            self.languages = languages
            self.responses = responses
            self.requests = requests
        }
    }
}
extension ServerProfile.Breakdown
{
    public
    init(_ stats:ServerProfile)
    {
        self.init(
            languages: stats.languages.chart(stratum: "Barbies served"),
            responses:
            (
                toBarbie: stats.responses.toBarbie.chart(
                    stratum: "responses to Barbies"),
                toBratz: stats.responses.toBratz.chart(
                    stratum: "responses to Bratz"),
                toGooglebot: stats.responses.toGooglebot.chart(
                    stratum: "responses to Googlebot"),
                toBingbot: stats.responses.toBingbot.chart(
                    stratum: "responses to Bingbot"),
                toOtherSearch: stats.responses.toOtherSearch.chart(
                    stratum: "responses to other search engines"),
                toOtherRobots: stats.responses.toOtherRobots.chart(
                    stratum: "responses to other robots")
            ),
            requests:
            (
                http2: stats.requests.http2.chart(
                    stratum: "pages served"),
                http1: stats.requests.http1.chart(
                    stratum: "pages served"),
                bytes: stats.requests.bytes.chart(
                    stratum: "bytes served")
            ))
    }
}
extension ServerProfile.Breakdown:HyperTextOutputStreamable
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.h3] = "Clients (HTTP/2)"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.requests.http2
            $0[.figcaption] { $0[.dl] = self.requests.http2.legend }
        }

        html[.h3] = "Clients (HTTP/1.1)"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.requests.http1
            $0[.figcaption] { $0[.dl] = self.requests.http1.legend }
        }

        html[.h3] = "Data Transfer"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.requests.bytes
            $0[.figcaption] { $0[.dl] = self.requests.bytes.legend }
        }

        html[.h3] = "Languages"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.languages
            $0[.figcaption] { $0[.dl] = self.languages.legend }
        }

        html[.h3] = "Responses (Barbies)"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.responses.toBarbie
            $0[.figcaption] { $0[.dl] = self.responses.toBarbie.legend }
        }

        html[.h3] = "Responses (Bratz)"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.responses.toBratz
            $0[.figcaption] { $0[.dl] = self.responses.toBratz.legend }
        }

        html[.h3] = "Responses (Googlebot)"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.responses.toGooglebot
            $0[.figcaption] { $0[.dl] = self.responses.toGooglebot.legend }
        }

        html[.h3] = "Responses (Bingbot)"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.responses.toBingbot
            $0[.figcaption] { $0[.dl] = self.responses.toBingbot.legend }
        }

        html[.h3] = "Responses (Other Search Engines)"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.responses.toOtherSearch
            $0[.figcaption] { $0[.dl] = self.responses.toOtherSearch.legend }
        }

        html[.h3] = "Responses (Other Robots)"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.responses.toOtherRobots
            $0[.figcaption] { $0[.dl] = self.responses.toOtherRobots.legend }
        }
    }
}
