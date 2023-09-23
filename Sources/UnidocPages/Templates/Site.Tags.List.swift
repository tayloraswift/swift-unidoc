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
        var page:[Item]

        init(package:PackageRecord, page:[Item])
        {
            self.package = package
            self.page = page
        }
    }
}
extension Site.Tags.List
{
    init(from output:PackageEditionsQuery.Output)
    {
        var prereleases:ArraySlice<Item> = output.prereleases.map(Item.init(facet:))[...]
        var releases:ArraySlice<Item> = output.releases.map(Item.init(facet:))[...]

        //  Merge the two pre-sorted arrays into a single sorted array.
        var items:[Item] = []
            items.reserveCapacity(prereleases.count + releases.count)
        while
            let prerelease:Item = prereleases.first,
            let release:Item = releases.first
        {
            if  release.edition.patch < prerelease.edition.patch
            {
                items.append(prerelease)
                prereleases.removeFirst()
            }
            else
            {
                items.append(release)
                releases.removeFirst()
            }
        }

        //  Append any remaining items.
        items += prereleases
        items += releases

        self.init(package: output.record, page: items)
    }
}
extension Site.Tags.List:RenderablePage
{
    var title:String { "Git Tags - \(self.package.id)" }
}
extension Site.Tags.List:StaticPage
{
    var location:URI { Site.Tags[self.package.id] }
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
                        $0[.th] = "ID"
                        $0[.th] = "Version"
                        $0[.th] = "Release?"
                        $0[.th] = "Archives?"
                    }
                }

                $0[.tbody]
                {
                    var modern:(prerelease:Bool, release:Bool) = (true, true)
                    for item:Item in self.page
                    {
                        if  item.edition.release
                        {
                            $0[.tr] { $0.class = modern.release ? "modern" : nil } = item

                            modern = (false, false)
                        }
                        else
                        {
                            $0[.tr] { $0.class = modern.prerelease ? "modern" : nil } = item

                            modern.prerelease = false
                        }
                    }
                }
            }
        }
    }
}
