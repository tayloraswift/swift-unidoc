import Media
import MongoDB
import HTML
import HTTP
import UnidocProfiling
import URI

extension Site
{
    @frozen public
    struct Admin
    {
        public
        let configuration:Mongo.ReplicaSetConfiguration

        public
        let errorsCrawling:Int
        public
        let reposCrawled:Int
        public
        let reposUpdated:Int
        public
        let tagsCrawled:Int
        public
        let tagsUpdated:Int

        public
        let tour:ServerTour
        public
        let real:Bool

        @inlinable public
        init(configuration:Mongo.ReplicaSetConfiguration,
            errorsCrawling:Int,
            reposCrawled:Int,
            reposUpdated:Int,
            tagsCrawled:Int,
            tagsUpdated:Int,
            tour:ServerTour,
            real:Bool)
        {
            self.configuration = configuration

            self.errorsCrawling = errorsCrawling
            self.reposCrawled = reposCrawled
            self.reposUpdated = reposUpdated
            self.tagsCrawled = tagsCrawled
            self.tagsUpdated = tagsUpdated

            self.tour = tour
            self.real = real
        }
    }
}
extension Site.Admin:StaticRoot
{
    @inlinable public static
    var root:String { "admin" }
}
extension Site.Admin
{
    static
    subscript(action:Action) -> URI
    {
        Self.uri.path / action.rawValue
    }
}
extension Site.Admin:RenderablePage
{
    public
    var title:String { "Administrator Tools" }
}
extension Site.Admin:AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder)
    {
        main[.h1] = "Welcome Empress!"

        main[.p]
        {
            $0 += "This is a "
            $0[.strong] = self.real ? "real" : "test"
            $0 += " deployment."
        }

        main[.hr]

        main[.nav, { $0.class = "admin" }]
        {
            $0[.ul]
            {
                $0[.li] { $0[.a] { $0.href = "\(Site.Admin.Recode.uri)" } = "Manage Schema" }
                $0[.li] { $0[.a] { $0.href = "\(Site.Admin.Slaves.uri)" } = "Manage Slaves" }
            }
        }

        main[.hr]

        main[.form]
        {
            $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
            $0.action = "\(Site.API[.index])"
            $0.method = "post"
        }
            content:
        {
            $0[.p]
            {
                $0[.code] = "https://github.com/"

                $0[.input]
                {
                    $0.type = "text"
                    $0.name = "owner"
                    $0.placeholder = "owner"
                }

                $0[.code] = "/"

                $0[.input]
                {
                    $0.type = "text"
                    $0.name = "repo"
                    $0.placeholder = "repo"
                }
            }
            $0[.p]
            {
                $0[.button] { $0.type = "submit" } = "Index GitHub Repository"
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
        for (action, label):(Site.API.Post, String) in
        [
            (
                .reloadAssets,
                "Reload Assets"
            ),
        ]
        {
            main[.hr]

            main[.form]
            {
                $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                $0.action = "\(Site.API[action])"
                $0.method = "post"
            }
                content:
            {
                $0[.p]
                {
                    $0[.button] { $0.type = "submit" } = label
                }
            }
        }

        //  Destructive actions.
        for action:Action in
        [
            .lintUnidocEditions,
            .dropUnidocDB,
            .dropAccountDB,
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

        main[.h2] = "Tour information"

        main[.dl]
        {
            $0[.dt] = "uptime"
            $0[.dd] = "\(self.tour.started.duration(to: .now))"

            $0[.dt] = "requests"
            $0[.dd] = "\(self.tour.profile.requests.pages.total)"


            $0[.dt] = "last request, including bots"
            $0[.dd] = self.tour.last.uri ?? "none"

            $0[.dt] = "last user-agent, including bots"
            $0[.dd] = self.tour.last.agent ?? "none"


            $0[.dt] = "last impression"
            $0[.dd] = self.tour.lastImpression.uri ?? "none"

            $0[.dt] = "last user-agent"
            $0[.dd] = self.tour.lastImpression.agent ?? "none"

            $0[.dt] = "last IP address"
            $0[.dd] = self.tour.lastImpression.ip?.description ?? "none"

            $0[.dt] = "last language"
            $0[.dd] = self.tour.lastImpression.language ?? "none"

            $0[.dt] = "last referrer"
            $0[.dd] = self.tour.lastImpression.referer ?? "none"

            if  let slowest:ServerTour.SlowestQuery = self.tour.slowestQuery
            {
                $0[.dt] = "slowest query"
                $0[.dd]
                {
                    $0[.a] { $0.href = "\(slowest.uri)" } = slowest.uri
                    $0 += " (\(slowest.duration))"
                }
            }

            $0[.dt] = "bytes transferred (content only)"
            $0[.dd] = "\(self.tour.profile.requests.bytes.total)"

            $0[.dt] = "GitHub crawling errors"
            $0[.dd] = "\(self.errorsCrawling)"

            $0[.dt] = "GitHub repos crawled"
            $0[.dd] = "\(self.reposCrawled)"

            $0[.dt] = "GitHub repos updated"
            $0[.dd] = "\(self.reposUpdated)"

            $0[.dt] = "GitHub tags crawled"
            $0[.dd] = "\(self.tagsCrawled)"

            $0[.dt] = "GitHub tags updated"
            $0[.dd] = "\(self.tagsUpdated)"
        }

        main += ServerProfile.Breakdown.init(self.tour.profile)

        main[.hr]

        main[.h2] = "Replica set information"

        main[.dl]
        {
            $0[.dt] = "name"
            $0[.dd] = self.configuration.name

            $0[.dt] = "members"
            $0[.dd] = "\(self.configuration.members.map(\.host.description))"

            $0[.dt] = "version"
            $0[.dd] = "\(self.configuration.version)"

            $0[.dt] = "term"
            $0[.dd] = "\(self.configuration.term)"
        }
    }
}
