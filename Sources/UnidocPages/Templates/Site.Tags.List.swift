import GitHubAPI
import HTML
import UnidocDB
import UnidocQueries
import UnidocRecords
import UnixTime
import URI

extension Site.Tags
{
    struct List
    {
        private
        let package:Realm.Package
        private
        var page:[Item]

        init(package:Realm.Package, page:[Item])
        {
            self.package = package
            self.page = page
        }
    }
}
extension Site.Tags.List
{
    init(from output:Realm.EditionsQuery.Output)
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

        self.init(package: output.package, page: items)
    }
}
extension Site.Tags.List:RenderablePage
{
    var title:String { "Git Tags - \(self.package.symbol)" }
}
extension Site.Tags.List:StaticPage
{
    var location:URI { Site.Tags[self.package.symbol] }
}
extension Site.Tags.List:ApplicationPage
{
    func main(_ main:inout HTML.ContentEncoder, assets:StaticAssets)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.h1] = "\(self.package.symbol)"
        }

        main[.section, { $0.class = "details" }]
        {
            if  let repo:Realm.Package.Repo = self.package.repo
            {
                $0[.h2] = "Package Repository"

                $0[.dl]
                {
                    switch repo
                    {
                    case .github(let repo):
                        let now:UnixInstant = .now()

                        $0[.dt] = "Provider"
                        $0[.dd]
                        {
                            $0[.a]
                            {
                                $0.href = "https://github.com/\(repo.owner.login)/\(repo.name)"
                                $0.target = "_blank"
                            } = "GitHub"
                        }

                        if  let license:GitHub.Repo.License = repo.license
                        {
                            $0[.dt] = "License"
                            $0[.dd] = license.name
                        }
                        if !repo.topics.isEmpty
                        {
                            $0[.dt] = "Keywords"
                            $0[.dd] = repo.topics.joined(separator: ", ")
                        }

                        $0[.dt] = "Owner"
                        $0[.dd] = repo.owner

                        $0[.dt] = "Watchers"
                        $0[.dd] = "\(repo.watchers)"

                        $0[.dt] = "Forks"
                        $0[.dd] = "\(repo.forks)"

                        $0[.dt] = "Stars"
                        $0[.dd] = "\(repo.stars)"

                        $0[.dt] = "Archived?"
                        $0[.dd] = repo.archived ? "yes" : "no"

                        if  let created:Timestamp.Components = .init(iso8601: repo.created)
                        {
                            $0[.dt] = "Created"
                            $0[.dd] = "\(created.month(.en)) \(created.day), \(created.year)"
                        }
                        if  let updated:Timestamp.Components = .init(iso8601: repo.updated),
                            let updated:UnixInstant = .init(utc: updated)
                        {
                            let age:Age<Language.EN> = .init(now - updated)

                            $0[.dt] = "Last Pushed"
                            $0[.dd] = "\(age)"
                        }
                    }
                }
            }

            $0[.h2] = "Package Tags"

            $0[.table, { $0.class = "tags" }]
            {
                $0[.thead]
                {
                    $0[.tr]
                    {
                        $0[.th] = "Tag"
                        $0[.th] = "Commit"
                        $0[.th] = "Release?"
                        $0[.th] = "Documentation"
                        $0[.th] = "Symbol Graphs"
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
