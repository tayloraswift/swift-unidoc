import HTML
import Durations
import HTTP
import Media
import MongoDB
import UnidocUI
import UnidocRender
import UnidocProfiling
import URI

extension Unidoc
{
    struct AdminPage
    {
        let servers:[(host:Mongo.Host, latency:Nanoseconds)]
        let plugins:[any Unidoc.ServerPlugin]

        let tour:ServerTour

        init(
            servers:[(host:Mongo.Host, latency:Nanoseconds)],
            plugins:[any Unidoc.ServerPlugin],
            tour:ServerTour)
        {
            self.servers = servers
            self.plugins = plugins
            self.tour = tour
        }
    }
}
extension Unidoc.AdminPage:Unidoc.StaticPage
{
    var location:URI { Unidoc.ServerRoot.admin.uri }
}
extension Unidoc.AdminPage:Unidoc.RenderablePage
{
    var title:String { "Administrator Tools" }
}
extension Unidoc.AdminPage:Unidoc.AdministrativePage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.h1] = "Welcome Empress!"

        main[.p]
        {
            $0 += "This is a "
            $0[.strong] = format.secure ? "real" : "test"
            $0 += " deployment."
        }

        main[.hr]

        main[.nav, { $0.class = "admin" }]
        {
            $0[.ul]
            {
                $0[.li] { $0[.a] { $0.href = "\(Unidoc.ReplicaSetPage.uri)" } = "RS" }
                $0[.li] { $0[.a] { $0.href = "\(Unidoc.CookiePage.uri)" } = "Cookies" }
                $0[.li] { $0[.a] { $0.href = "\(Recode.uri)" } = "Manage Schema" }

                for plugin:any Unidoc.ServerPlugin in self.plugins
                {
                    $0[.li]
                    {
                        $0[.a] { $0.href = "/plugin/\(plugin.id)" } = plugin.id
                    }
                }
            }
        }

        //  Non-destructive actions.
        main[.hr]

        main[.form]
        {
            $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
            $0.action = "\(Unidoc.Post[.uplinkAll])"
            $0.method = "post"
        }
            content:
        {
            $0[.p]
            {
                $0[.button] { $0.type = "submit" } = "Uplink all symbol graphs"
            }
        }

        main[.form]
        {
            $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
            $0.action = "\(Unidoc.Post[.telescope])"
            $0.method = "post"
        }
            content:
        {
            $0[.p]
            {
                $0[.input]
                {
                    $0.type = "number"
                    $0.name = "days"
                    $0.placeholder = "days"
                }
            }

            $0[.p]
            {
                $0[.button] { $0.type = "submit" } = "Activate Package Telescope"
            }
        }

        main[.hr]

        main[.h2] = "Database servers"
        main[.dl]
        {
            for (host, latency):(Mongo.Host, Nanoseconds) in self.servers
            {
                $0[.dt] = "\(host)"
                $0[.dd] = "\(latency.rawValue / 1_000) µs"
            }
        }

        main[.hr]

        main[.h2] = "Tour information"
        main[.dl]
        {

            $0[.dt] = "Uptime"
            $0[.dd] = "\(self.tour.started.duration(to: .now))"

            let requests:Int =
                self.tour.profile.requests.http1.total +
                self.tour.profile.requests.http2.total

            $0[.dt] = "Requests"
            $0[.dd] = "\(requests)"

            $0[.dt] = "Requests (Barbies)"
            $0[.dd] = "\(self.tour.profile.requests.http2.barbie)"

            $0[.dt] = "Server errors"
            $0[.dd] = "\(self.tour.errors)"
        }

        main[.h2] = "Headers"

        if  let last:ServerTour.Request = self.tour.lastImpression
        {
            main[.h3] = "Last Impression"
            main[.dl] = last
        }
        if  let last:ServerTour.Request = self.tour.lastSearchbot
        {
            main[.h3] = "Last Searchbot"
            main[.dl] = last
        }
        if  let last:ServerTour.Request = self.tour.lastRequest
        {
            main[.h3] = "Last Request"
            main[.dl] = last
        }

        main[.h2] = "Performance"

        main[.dl]
        {
            if  let query:ServerTour.SlowestQuery = self.tour.slowestQuery
            {
                let uri:String = "\(query.uri)"

                $0[.dt] = "slowest query"
                $0[.dd]
                {
                    $0[.a] { $0.href = "\(uri)" } = "\(uri)"
                    $0 += " (\(query.time))"
                }
            }

            $0[.dt] = "bytes transferred (content only)"
            $0[.dd] = "\(self.tour.profile.requests.bytes.total)"
        }

        main += self.tour.profile
    }
}
