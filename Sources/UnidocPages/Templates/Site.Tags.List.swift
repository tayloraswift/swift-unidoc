import HTML
import UnidocDB
import UnidocQueries
import URI

extension Site.Tags
{
    struct List
    {
        private
        let package:PackageRecord
        private
        var latestPrerelease:Item?
        private
        var latestRelease:Item?
        private
        var page:[Item]

        init(package:PackageRecord,
            latestPrerelease:Item? = nil,
            latestRelease:Item? = nil,
            page:[Item] = [])
        {
            self.package = package
            self.latestPrerelease = latestPrerelease
            self.latestRelease = latestRelease
            self.page = page
        }
    }
}
extension Site.Tags.List
{
    init(from output:PackageEditionsQuery.Output)
    {
        self.init(package: output.record)

        var seen:Set<Int32> = []
        for facet:PackageEditionsQuery.Facet in output.facets
        {
            guard
            let release:Bool = facet.release
            else
            {
                continue
            }

            guard case nil = seen.update(with: facet.edition.version)
            else
            {
                continue
            }

            if  release
            {
                self.latestRelease = .init(facet: facet)
            }
            else
            {
                self.latestPrerelease = .init(facet: facet)
            }
        }
        for facet:PackageEditionsQuery.Facet in output.facets
        {
            if  case nil = seen.update(with: facet.edition.version)
            {
                self.page.append(.init(facet: facet))
            }
        }
    }
}
extension Site.Tags.List:FixedPage
{
    var location:URI { Site.Tags[self.package.id] }
    var title:String { "Git Tags - \(self.package.id)" }
}
extension Site.Tags.List:AdministrativePage
{
    func main(_ main:inout HTML.ContentEncoder)
    {
        main[.h1] = "\(self.package.id) (tags)"
        main[.section, { $0.class = "details" }]
        {
            $0[.table, { $0.class = "tags" }]
            {
                $0[.thead]
                {
                    $0[.tr]
                    {
                        $0[.th] = "Git Ref"
                        $0[.th] = "Commit"
                        $0[.th] = "Semver"
                        $0[.th] = "ID"
                        $0[.th] = "Archives?"
                    }
                }

                $0[.tbody]
                {
                    $0[.tr] { $0.class = "latest prerelease" } = self.latestPrerelease
                    $0[.tr] { $0.class = "latest release" } = self.latestRelease

                    for item:Item in self.page
                    {
                        $0[.tr] = item
                    }
                }
            }
        }
    }
}
