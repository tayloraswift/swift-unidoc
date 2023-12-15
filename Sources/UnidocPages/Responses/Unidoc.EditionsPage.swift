import GitHubAPI
import HTML
import Media
import UnidocDB
import UnidocQueries
import UnidocRecords
import UnixTime
import URI

extension Unidoc
{
    struct EditionsPage
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
extension Unidoc.EditionsPage
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
extension Unidoc.EditionsPage:RenderablePage
{
    var title:String { "Git Tags - \(self.package.symbol)" }
}
extension Unidoc.EditionsPage:StaticPage
{
    var location:URI { Swiftinit.Tags[self.package.symbol] }
}
extension Unidoc.EditionsPage:ApplicationPage
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
                        let row:Row = .init(name: output.edition.name,
                            sha1: output.edition.sha1?.description,
                            release: output.edition.release,
                            version: output.edition.patch,
                            volume: output.volume,
                            graph: output.graph)

                        if  output.edition.release
                        {
                            $0[.tr] { $0.class = modern.release ? "modern" : nil } = row

                            modern = (false, false)
                        }
                        else
                        {
                            $0[.tr] { $0.class = modern.prerelease ? "modern" : nil } = row

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
                    if  let realm:Unidoc.RealmMetadata = self.realm
                    {
                        $0[.span] = realm.symbol

                        guard self.package.realmAligning
                        else
                        {
                            return
                        }

                        $0[.span] { $0.class = "placeholder" } = "alignment in progress"
                    }
                    else
                    {
                        $0[.span] { $0.class = "placeholder" } = "none"
                    }

                }
            }

            guard self.user?.maintains(package: self.package) ?? !format.secure
            else
            {
                return
            }

            $0[.form]
            {
                $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                $0.action = "\(Swiftinit.API[.alignPackage])"
                $0.method = "post"
            }
                content:
            {
                $0[.p]
                {
                    $0[.input]
                    {
                        $0.type = "hidden"
                        $0.name = "package"
                        $0.value = "\(self.package.symbol)"
                    }

                    $0[.input]
                    {
                        $0.type = "text"
                        $0.name = "realm"
                        $0.placeholder = "realm"
                    }

                    $0[.label]
                    {
                        $0.class = "checkbox"
                        $0.title = "Create the realm if it does not exist."
                    }
                        content:
                    {
                        $0[.input]
                        {
                            $0.type = "checkbox"
                            $0.name = "force"
                            $0.value = "true"
                        }

                        $0[.span] = "Create Realm"
                    }
                }
                $0[.p]
                {
                    $0[.button] { $0.type = "submit" } = "Transfer Package"
                }
            }

            $0[.form]
            {
                $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                $0.action = "\(Swiftinit.API[.indexRepoTag])"
                $0.method = "post"
            }
                content:
            {
                $0[.p]
                {
                    $0[.input]
                    {
                        $0.type = "hidden"
                        $0.name = "package"
                        $0.value = "\(self.package.symbol)"
                    }

                    $0[.input]
                    {
                        $0.type = "text"
                        $0.name = "tag"
                        $0.placeholder = "tag"
                    }
                }
                $0[.p]
                {
                    $0[.button] { $0.type = "submit" } = "Index GitHub Tag"
                }
            }
        }
    }
}
