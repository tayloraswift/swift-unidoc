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
        let package:Unidoc.PackageMetadata
        private
        let editions:[Unidoc.EditionOutput]
        private
        let realm:Unidoc.RealmMetadata?
        private
        let user:Unidoc.User?

        init(package:Unidoc.PackageMetadata,
            editions:[Unidoc.EditionOutput],
            realm:Unidoc.RealmMetadata?,
            user:Unidoc.User?)
        {
            self.package = package
            self.editions = editions
            self.realm = realm
            self.user = user
        }
    }
}
extension Site.Tags.List
{
    init(from output:Unidoc.EditionsQuery.Output)
    {
        var prereleases:ArraySlice<Unidoc.EditionOutput> = output.prereleases[...]
        var releases:ArraySlice<Unidoc.EditionOutput> = output.releases[...]

        //  Merge the two pre-sorted arrays into a single sorted array.
        var editions:[Unidoc.EditionOutput] = []
            editions.reserveCapacity(prereleases.count + releases.count)
        while
            let prerelease:Unidoc.EditionOutput = prereleases.first,
            let release:Unidoc.EditionOutput = releases.first
        {
            if  release.edition.patch < prerelease.edition.patch
            {
                editions.append(prerelease)
                prereleases.removeFirst()
            }
            else
            {
                editions.append(release)
                releases.removeFirst()
            }
        }

        //  Append any remaining items.
        editions += prereleases
        editions += releases

        self.init(package: output.package,
            editions: editions,
            realm: output.realm,
            user: output.user)
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
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.h1] = "\(self.package.symbol)"
        }

        main[.section, { $0.class = "details" }]
        {
            if  let repo:Unidoc.PackageMetadata.Repo = self.package.repo
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
                        $0[.th] = "Docs"
                        $0[.th] = "Symbol Graph"
                    }
                }

                $0[.tbody]
                {
                    var modern:(prerelease:Bool, release:Bool) = (true, true)
                    for output:Unidoc.EditionOutput in self.editions
                    {
                        let item:Item = .init(name: output.edition.name,
                            sha1: output.edition.sha1?.description,
                            release: output.edition.release,
                            version: output.edition.patch,
                            volume: output.volume,
                            graph: output.graph)

                        if  output.edition.release
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

            $0[.h2] = "Package Settings"

            $0[.dl]
            {
                $0[.dt] = "Realm"
                $0[.dd]
                {
                    $0.class = self.realm.map { _ in "realm" }
                } = self.realm?.symbol ?? "none"
            }

            guard
            case .administratrix? = self.user?.level
            else
            {
                return
            }
        }
    }
}
