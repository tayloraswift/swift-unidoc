import HTML
import HTTP
import MongoDB
import Swiftinit
import SwiftinitRender
import URI

extension Swiftinit
{
    struct ReplicaSetPage
    {
        let configuration:Mongo.ReplicaSetConfiguration

        init(configuration:Mongo.ReplicaSetConfiguration)
        {
            self.configuration = configuration
        }
    }
}
extension Swiftinit.ReplicaSetPage
{
    static
    var name:String { "rs" }

    static
    var uri:URI { Swiftinit.Root.admin / Self.name }
}
extension Swiftinit.ReplicaSetPage:Unidoc.RenderablePage
{
    var title:String { "Replica set information" }
}
extension Swiftinit.ReplicaSetPage:Unidoc.StaticPage
{
    var location:URI { Self.uri }
}
extension Swiftinit.ReplicaSetPage:Unidoc.AdministrativePage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.h1] = "Replica set"
        main[.dl]
        {
            $0[.dt] = "name"
            $0[.dd] = self.configuration.name

            $0[.dt] = "members"
            $0[.dd] = "\(self.configuration.members.map(\.host.description))"

            $0[.dt] = "version"
            $0[.dd] = "\(self.configuration.version)"

            if  let term:Int = self.configuration.term
            {
                $0[.dt] = "term"
                $0[.dd] = "\(term)"
            }
        }
    }
}
