import GitHubAPI
import HTML
import Symbols

extension GitHub.RepoMonitor.Event
{
    struct Fetch
    {
        let package:Symbol.Package
        var prerelease:Unidoc.EditionMetadata?
        var release:Unidoc.EditionMetadata?
        var crawled:Int
        var updated:Int

        init(package:Symbol.Package)
        {
            self.package = package
            self.prerelease = nil
            self.release = nil
            self.crawled = 0
            self.updated = 0
        }
    }
}
extension GitHub.RepoMonitor.Event.Fetch:HTML.OutputStreamable
{
    static
    func += (dl:inout HTML.ContentEncoder, self:Self)
    {
        dl[.dt] = "Package"
        dl[.dd]
        {
            $0[.a] { $0.href = "\(Unidoc.TagsEndpoint[self.package])" } = "\(self.package)"
        }

        if  let prerelease:Unidoc.EditionMetadata = self.prerelease
        {
            dl[.dt] = "Prerelease"
            dl[.dd] = prerelease.name
        }

        if  let release:Unidoc.EditionMetadata = self.release
        {
            dl[.dt] = "Release"
            dl[.dd] = release.name
        }

        dl[.dt] = "Tags crawled"
        dl[.dd] = "\(self.crawled)"

        dl[.dt] = "Tags updated"
        dl[.dd] = "\(self.updated)"
    }
}
