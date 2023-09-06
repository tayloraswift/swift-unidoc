import MongoDB
import HTML
import HTTPServer
import URI

extension Site
{
    @frozen public
    struct Admin
    {
        public
        let configuration:Mongo.ReplicaSetConfiguration
        public
        let tour:ServerTour

        @inlinable public
        init(configuration:Mongo.ReplicaSetConfiguration, tour:ServerTour)
        {
            self.configuration = configuration
            self.tour = tour
        }
    }
}
extension Site.Admin:FixedRoot
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
extension Site.Admin:FixedPage
{
    public
    var title:String { "Administrator Tools" }
}
extension Site.Admin:AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder)
    {
        main[.h2] = "Welcome Empress!"

        main[.form]
        {
            $0.enctype = "multipart/form-data"
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

        main[.hr]

        main[.form]
        {
            $0.enctype = "multipart/form-data"
            $0.action = "\(Self[.rebuild])"
            $0.method = "post"
        }
        content:
        {
            $0[.p]
            {
                $0[.button] { $0.type = "submit" } = Action.rebuild.label
            }
        }

        for action:Action in [.dropUnidocDB, .dropAccountDB]
        {
            main[.hr]

            main[.form]
            {
                $0.enctype = "application/x-www-form-urlencoded"
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
            $0[.dd] = "\(self.tour.stats.requests.total)"

            $0[.dt] = "bytes transferred (content only)"
            $0[.dd] = "\(self.tour.stats.bytes.total)"
        }

        main += ServerTour.StatsBreakdown.init(self.tour.stats)

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
