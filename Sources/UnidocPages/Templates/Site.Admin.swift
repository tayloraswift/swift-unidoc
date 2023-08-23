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
        var configuration:Mongo.ReplicaSetConfiguration

        @inlinable public
        init(configuration:Mongo.ReplicaSetConfiguration)
        {
            self.configuration = configuration
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
    func confirm(_ action:Site.Action) -> URI
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
        main[.form]
        {
            $0.enctype = "multipart/form-data"
            $0.action = "\(Site.Action.upload)"
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
                $0[.button] { $0.type = "submit" } = "Upload Snapshots"
            }
        }

        main[.hr]

        main[.form]
        {
            $0.enctype = "multipart/form-data"
            $0.action = "\(Site.Action.rebuild)"
            $0.method = "post"
        }
        content:
        {
            $0[.p]
            {
                $0[.button] { $0.type = "submit" } = "Rebuild Collections"
            }
        }

        main[.hr]

        main[.form]
        {
            $0.enctype = "application/x-www-form-urlencoded"
            $0.action = "\(Self.confirm(.dropDatabase))"
            $0.method = "get"
        }
        content:
        {
            $0[.p]
            {
                $0[.button] { $0.type = "submit" } = "Drop Database"
            }
        }

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
