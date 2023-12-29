import HTML
import Media

@frozen public
struct ServerProfile
{
    public
    var languages:ByLanguage

    public
    var responses:
    (
        toBarbie:ByStatus,
        toBratz:ByStatus,
        toGooglebot:ByStatus,
        toBingbot:ByStatus,
        toOtherSearch:ByStatus,
        toOtherRobots:ByStatus
    )
    public
    var requests:
    (
        http2:ByClient,
        http1:ByClient,
        bytes:ByClient
    )

    @inlinable public
    init(
        languages:ByLanguage = [:],
        responses:
        (
            toBarbie:ByStatus,
            toBratz:ByStatus,
            toGooglebot:ByStatus,
            toBingbot:ByStatus,
            toOtherSearch:ByStatus,
            toOtherRobots:ByStatus
        ) = ([:], [:], [:], [:], [:], [:]),
        requests:
        (
            http2:ByClient,
            http1:ByClient,
            bytes:ByClient
        ) = ([:], [:], [:]))
    {
        self.languages = languages
        self.responses = responses
        self.requests = requests
    }
}
extension ServerProfile:HTML.OutputStreamable
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.h3] = "Clients (HTTP/2)"
        html[.figure, { $0.class = "chart client" }] = self.requests.http2.chart
        {
            """
            \($1) percent of the pages served over HTTP/2 \
            during this tour were served to \($0.name)
            """
        }

        html[.h3] = "Clients (HTTP/1.1)"
        html[.figure, { $0.class = "chart client" }] = self.requests.http1.chart
        {
            """
            \($1) percent of the pages served over HTTP/1.1 \
            during this tour were served to \($0.name)
            """
        }

        html[.h3] = "Data Transfer"
        html[.figure, { $0.class = "chart client" }] = self.requests.bytes.chart
        {
            """
            \($1) percent of the bytes transferred \
            during this tour were served to \($0.name)
            """
        }

        html[.h3] = "Languages"
        html[.figure, { $0.class = "chart language" }] = self.languages.chart
        {
            """
            \($1) percent of the pages served during this tour \
            were served to Barbies who spoke \($0.id)
            """
        }

        html[.h3] = "Responses (Barbies)"
        html[.figure, { $0.class = "chart status" }] = self.responses.toBarbie.chart
        {
            """
            \($1) percent of the responses to Barbies \
            during this tour were \($0.name)
            """
        }

        html[.h3] = "Responses (Bratz)"
        html[.figure, { $0.class = "chart status" }] = self.responses.toBratz.chart
        {
            """
            \($1) percent of the responses to Bratz \
            during this tour were \($0.name)
            """
        }

        html[.h3] = "Responses (Googlebot)"
        html[.figure, { $0.class = "chart status" }] = self.responses.toGooglebot.chart
        {
            """
            \($1) percent of the responses to Googlebot \
            during this tour were \($0.name)
            """
        }

        html[.h3] = "Responses (Bingbot)"
        html[.figure, { $0.class = "chart status" }] = self.responses.toBingbot.chart
        {
            """
            \($1) percent of the responses to Bingbot \
            during this tour were \($0.name)
            """
        }

        html[.h3] = "Responses (Other Search Engines)"
        html[.figure, { $0.class = "chart status" }] = self.responses.toOtherSearch.chart
        {
            """
            \($1) percent of the responses to other search engines \
            during this tour were \($0.name)
            """
        }

        html[.h3] = "Responses (Other Robots)"
        html[.figure, { $0.class = "chart status" }] = self.responses.toOtherRobots.chart
        {
            """
            \($1) percent of the responses to other robots \
            during this tour were \($0.name)
            """
        }
    }
}
