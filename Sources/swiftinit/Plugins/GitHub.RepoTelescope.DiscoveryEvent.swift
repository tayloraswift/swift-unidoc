import GitHubAPI
import HTML
import Symbols

extension GitHub.RepoTelescope
{
    struct DiscoveryEvent
    {
        let package:Symbol.Package

        init(package:Symbol.Package)
        {
            self.package = package
        }
    }
}
extension GitHub.RepoTelescope.DiscoveryEvent:Unidoc.ServerPluginEvent
{
    static
    var name:String { "Discovered package" }
}
extension GitHub.RepoTelescope.DiscoveryEvent:HTML.OutputStreamable
{
    static
    func += (dl:inout HTML.ContentEncoder, self:Self)
    {
        dl[.dt] = "Symbol"
        dl[.dd]
        {
            $0[.a] { $0.href = "\(Unidoc.TagsEndpoint[self.package])" } = "\(self.package)"
        }
    }
}
