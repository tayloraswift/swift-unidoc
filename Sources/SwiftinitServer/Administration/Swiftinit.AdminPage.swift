import HTML
import Durations
import HTTP
import Media
import MongoDB
import Swiftinit
import SwiftinitRender
import UnidocProfiling
import URI

extension Swiftinit
{
    struct AdminPage
    {
        let servers:[(host:Mongo.Host, latency:Nanoseconds)]
        let plugins:[any Swiftinit.ServerPlugin]

        let tour:ServerTour

        init(
            servers:[(host:Mongo.Host, latency:Nanoseconds)],
            plugins:[any Swiftinit.ServerPlugin],
            tour:ServerTour)
        {
            self.servers = servers
            self.plugins = plugins
            self.tour = tour
        }
    }
}
extension Swiftinit.AdminPage
{
    static
    subscript(action:Action) -> URI
    {
        Swiftinit.Root.admin / action.rawValue
    }
}
extension Swiftinit.AdminPage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Root.admin.uri }
}
extension Swiftinit.AdminPage:Swiftinit.RenderablePage
{
    var title:String { "Administrator Tools" }
}
extension Swiftinit.AdminPage:Swiftinit.AdministrativePage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
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
                $0[.li] { $0[.a] { $0.href = "\(Swiftinit.ReplicaSetPage.uri)" } = "RS" }
                $0[.li] { $0[.a] { $0.href = "\(Swiftinit.CookiePage.uri)" } = "Cookies" }
                $0[.li] { $0[.a] { $0.href = "\(Recode.uri)" } = "Manage Schema" }

                for plugin:any Swiftinit.ServerPlugin in self.plugins
                {
                    $0[.li]
                    {
                        $0[.a] { $0.href = "/plugin/\(plugin.id)" } = plugin.id
                    }
                }
            }
        }

        main[.hr]

        main[.form]
        {
            $0.enctype = "\(MultipartType.form_data)"
            $0.action = "\(Self[.upload])"
            $0.method = "post"
        }
            content:
        {
            $0[.p]
            {
                $0[.input]
                {
                    $0.multiple = true
                    $0.name = "documentation-binary"
                    $0.type = "file"
                }
            }
            $0[.p]
            {
                $0[.button] { $0.type = "submit" } = Action.upload.label
            }
        }

        //  Non-destructive actions.
        main[.hr]

        main[.form]
        {
            $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
            $0.action = "\(Swiftinit.API[.uplinkAll])"
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
            $0.action = "\(Swiftinit.API[.telescope])"
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

        //  Destructive actions.
        for action:Action in
        [
            .dropUnidocDB,
            .restart,
        ]
        {
            main[.hr]

            main[.form]
            {
                $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                $0.action = "\(Self[action])"
                $0.method = "get"
            }
                content:
            {
                $0[.p]
                {
                    $0[.button] { $0.type = "submit" } = action.label
                }
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

        main[.h2] = "Performance"

        main[.dl]
        {
            if  let last:ServerTour.Request = self.tour.lastImpression
            {
                $0[.h3] = "Last Impression"

                $0[.dt] = "Path"
                $0[.dd] { $0[.a] { $0.href = last.path } = last.path }

                $0[.dt] = "User Agent"
                $0[.dd] = last.headers.userAgent ?? "none"

                $0[.dt] = "IP address"
                $0[.dd] = "\(last.address)"

                $0[.dt] = "Accept Language"
                $0[.dd] = last.headers.acceptLanguage ?? "none"

                $0[.dt] = "Referrer"
                $0[.dd] = last.headers.referer ?? "none"
            }
            if  let last:ServerTour.Request = self.tour.lastSearchbot
            {
                $0[.h3] = "Last Searchbot"

                $0[.dt] = "Path"
                $0[.dd] { $0[.a] { $0.href = last.path } = last.path }

                $0[.dt] = "User Agent"
                $0[.dd] = last.headers.userAgent ?? "none"

                $0[.dt] = "IP address"
                $0[.dd] = "\(last.address)"

                $0[.dt] = "Accept Language"
                $0[.dd] = last.headers.acceptLanguage ?? "none"
            }
            if  let last:ServerTour.Request = self.tour.lastRequest
            {
                $0[.h3] = "Last Request"

                $0[.dt] = "Path"
                $0[.dd] { $0[.a] { $0.href = last.path } = last.path }

                $0[.dt] = "User Agent"
                $0[.dd] = last.headers.userAgent ?? "none"

                $0[.dt] = "IP address"
                $0[.dd] = "\(last.address)"

                $0[.dt] = "Accept Language"
                $0[.dd] = last.headers.acceptLanguage ?? "none"
            }

            if  let query:ServerTour.SlowestQuery = self.tour.slowestQuery
            {
                $0[.dt] = "slowest query"
                $0[.dd]
                {
                    $0[.a] { $0.href = "\(query.path)" } = query.path
                    $0 += " (\(query.time))"
                }
            }

            $0[.dt] = "bytes transferred (content only)"
            $0[.dd] = "\(self.tour.profile.requests.bytes.total)"
        }

        main += self.tour.profile
    }
}
