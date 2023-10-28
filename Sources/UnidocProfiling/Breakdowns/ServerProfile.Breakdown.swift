import HTML

extension ServerProfile
{
    @frozen public
    struct Breakdown
    {
        private
        var languages:Pie<ByLanguage.Stat>
        private
        var protocols:
        (
            toBarbie:Pie<ByProtocol.Stat>,
            toBratz:Pie<ByProtocol.Stat>,
            toSearch:Pie<ByProtocol.Stat>,
            toOther:Pie<ByProtocol.Stat>
        )
        private
        var responses:
        (
            toBarbie:Pie<ByStatus.Stat>,
            toBratz:Pie<ByStatus.Stat>,
            toSearch:Pie<ByStatus.Stat>,
            toOther:Pie<ByStatus.Stat>
        )
        private
        var requests:
        (
            pages:Pie<ByAgent.Stat>,
            bytes:Pie<ByAgent.Stat>
        )

        private
        init(
            languages:Pie<ByLanguage.Stat>,
            protocols:
            (
                toBarbie:Pie<ByProtocol.Stat>,
                toBratz:Pie<ByProtocol.Stat>,
                toSearch:Pie<ByProtocol.Stat>,
                toOther:Pie<ByProtocol.Stat>
            ),
            responses:
            (
                toBarbie:Pie<ByStatus.Stat>,
                toBratz:Pie<ByStatus.Stat>,
                toSearch:Pie<ByStatus.Stat>,
                toOther:Pie<ByStatus.Stat>
            ),
            requests:
            (
                pages:Pie<ByAgent.Stat>,
                bytes:Pie<ByAgent.Stat>
            ))
        {
            self.languages = languages
            self.protocols = protocols
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
            protocols:
            (
                toBarbie: stats.protocols.toBarbie.chart(
                    stratum: "requests made by Barbies"),
                toBratz: stats.protocols.toBratz.chart(
                    stratum: "requests made by Bratz"),
                toSearch: stats.protocols.toSearch.chart(
                    stratum: "requests made by Search Engines"),
                toOther: stats.protocols.toOther.chart(
                    stratum: "requests made by others")
            ),
            responses:
            (
                toBarbie: stats.responses.toBarbie.chart(
                    stratum: "responses to Barbies"),
                toBratz: stats.responses.toBratz.chart(
                    stratum: "responses to Bratz"),
                toSearch: stats.responses.toSearch.chart(
                    stratum: "responses to Search Engines"),
                toOther: stats.responses.toOther.chart(
                    stratum: "responses to others")
            ),
            requests:
            (
                pages: stats.requests.pages.chart(
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
        html[.h3] = "Agents"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.requests.pages
            $0[.figcaption] { $0[.dl] = self.requests.pages.legend }
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

        html[.h3] = "Responses (Search Engines)"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.responses.toSearch
            $0[.figcaption] { $0[.dl] = self.responses.toSearch.legend }
        }

        html[.h3] = "Responses (Others)"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.responses.toOther
            $0[.figcaption] { $0[.dl] = self.responses.toOther.legend }
        }

        html[.h3] = "Protocols (Barbies)"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.protocols.toBarbie
            $0[.figcaption] { $0[.dl] = self.protocols.toBarbie.legend }
        }

        html[.h3] = "Protocols (Bratz)"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.protocols.toBratz
            $0[.figcaption] { $0[.dl] = self.protocols.toBratz.legend }
        }

        html[.h3] = "Protocols (Search Engines)"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.protocols.toSearch
            $0[.figcaption] { $0[.dl] = self.protocols.toSearch.legend }
        }

        html[.h3] = "Protocols (Others)"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.protocols.toOther
            $0[.figcaption] { $0[.dl] = self.protocols.toOther.legend }
        }
    }
}
