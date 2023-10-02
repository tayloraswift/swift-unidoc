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
            toBrowsers:Pie<ByStatus.Stat>,
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
            responses:
            (
                toBrowsers:Pie<ByStatus.Stat>,
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
                toBrowsers: stats.responses.toBrowsers.chart(
                    stratum: "responses to Barbies"),
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
            $0[.div] { $0.class = "pie" } = self.responses.toBrowsers
            $0[.figcaption] { $0[.dl] = self.responses.toBrowsers.legend }
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
    }
}
