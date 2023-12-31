import BSON
import GitHubAPI
import HTML
import Media
import UnidocDB
import UnidocQueries
import UnidocRecords
import UnixTime
import URI

extension Swiftinit
{
    struct TagsPage
    {
        private
        let package:Unidoc.PackageMetadata
        private
        let tagless:Unidoc.VersionsQuery.Tagless?
        private
        let tagged:[Unidoc.VersionsQuery.Tag]
        private
        let realm:Unidoc.RealmMetadata?
        private
        let user:Unidoc.User?

        init(package:Unidoc.PackageMetadata,
            tagless:Unidoc.VersionsQuery.Tagless?,
            tagged:[Unidoc.VersionsQuery.Tag],
            realm:Unidoc.RealmMetadata?,
            user:Unidoc.User?)
        {
            self.package = package
            self.tagless = tagless
            self.tagged = tagged
            self.realm = realm
            self.user = user
        }
    }
}
extension Swiftinit.TagsPage
{
    init(from output:borrowing Unidoc.VersionsQuery.Output)
    {
        var prereleases:ArraySlice<Unidoc.VersionsQuery.Tag> = output.prereleases[...]
        var releases:ArraySlice<Unidoc.VersionsQuery.Tag> = output.releases[...]

        //  Merge the two pre-sorted arrays into a single sorted array.
        var tagged:[Unidoc.VersionsQuery.Tag] = []
            tagged.reserveCapacity(prereleases.count + releases.count)
        while
            let prerelease:Unidoc.VersionsQuery.Tag = prereleases.first,
            let release:Unidoc.VersionsQuery.Tag = releases.first
        {
            if  release.edition.patch < prerelease.edition.patch
            {
                tagged.append(prerelease)
                prereleases.removeFirst()
            }
            else
            {
                tagged.append(release)
                releases.removeFirst()
            }
        }

        //  Append any remaining items.
        tagged += prereleases
        tagged += releases

        self.init(package: output.package,
            tagless: output.tagless,
            tagged: tagged,
            realm: output.realm,
            user: output.user)
    }
}
extension Swiftinit.TagsPage:Swiftinit.RenderablePage
{
    var title:String { "Git Tags · \(self.package.symbol)" }
}
extension Swiftinit.TagsPage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Tags[self.package.symbol] }
}
extension Swiftinit.TagsPage:Swiftinit.ApplicationPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        let now:UnixInstant = .now()

        main[.section, { $0.class = "introduction" }]
        {
            $0[.h1] = "\(self.package.symbol)"

            if  let repo:Unidoc.PackageRepo = self.package.repo
            {
                $0 += Swiftinit.PackageBanner.init(repo: repo, now: now)
            }
        }

        main[.section, { $0.class = "details" }]
        {
            if  let repo:Unidoc.PackageRepo = self.package.repo
            {
                $0[.h2] = "Package Repository"

                $0[.dl]
                {
                    let created:UnixInstant

                    switch repo.origin
                    {
                    case .github(let origin):
                        $0[.dt] = "Provider"
                        $0[.dd] = "GitHub"

                        if  let license:Unidoc.PackageLicense = repo.license
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
                        $0[.dd] = origin.owner

                        $0[.dt] = "Watchers"
                        $0[.dd] = "\(origin.watchers)"

                        $0[.dt] = "Forks"
                        $0[.dd] = "\(repo.forks)"

                        $0[.dt] = "Archived?"
                        $0[.dd] = origin.archived ? "yes" : "no"

                        created = .millisecond(repo.created.value)
                    }
                    if  let created:Timestamp.Date = created.timestamp?.date
                    {
                        $0[.dt] = "Created"
                        $0[.dd]
                        {
                            $0[.a]
                            {
                                $0.href = "\(Swiftinit.Telescope[created])"
                            } = "\(created.month(.en)) \(created.day), \(created.year)"
                        }
                    }
                }
            }

            $0[.h2] = Heading.tags

            $0[.table, { $0.class = "tags" }]
            {
                $0[.thead]
                {
                    $0[.tr]
                    {
                        $0[.th] = "Tag"
                        $0[.th] = "Commit"
                        $0[.th] = "Docs"
                        $0[.th] = "Symbol Graph"
                    }
                }

                $0[.tbody]
                {
                    if  let tagless:Unidoc.VersionsQuery.Tagless = self.tagless
                    {
                        $0[.tr] { $0.class = "tagless" } = Row.init(
                            volume: tagless.volume,
                            graph: tagless.graph,
                            type: .tagless)
                    }

                    var modern:(prerelease:Bool, release:Bool) = (true, true)
                    for tagged:Unidoc.VersionsQuery.Tag in self.tagged
                    {
                        let row:Row = .init(
                            volume: tagged.volume,
                            graph: tagged.graph,
                            type: .tagged(
                                tagged.edition.name,
                                tagged.edition.sha1,
                                tagged.edition.patch,
                                release: tagged.edition.release))

                        if  tagged.edition.release
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

            $0[.h2] = Heading.settings

            $0[.dl]
            {
                $0[.dt] = "Realm"
                $0[.dd]
                {
                    if  let realm:Unidoc.RealmMetadata = self.realm
                    {
                        $0[.a]
                        {
                            $0.href = "\(Swiftinit.Realm[realm.symbol])"
                        } = realm.symbol

                        guard self.package.realmAligning
                        else
                        {
                            return
                        }

                        $0 += " "
                        $0[.span] { $0.class = "parenthetical" } = "alignment in progress"
                    }
                    else
                    {
                        $0[.span] { $0.class = "placeholder" } = "none"
                    }
                }

                $0[.dt] = "Hidden"
                $0[.dd] = self.package.hidden ? "yes" : "no"

                if  let crawled:BSON.Millisecond = self.package.repo?.crawled
                {
                    let crawled:UnixInstant = .millisecond(crawled.value)
                    let age:Age = .init(now - crawled)

                    $0[.dt] = "Repo read"
                    $0[.dd] = "\(age.long) ago"
                }
                if  let crawled:BSON.Millisecond = self.package.crawled
                {
                    let crawled:UnixInstant = .millisecond(crawled.value)
                    let age:Age = .init(now - crawled)

                    $0[.dt] = "Tags read"
                    $0[.dd] = self.package.crawlingIntervalTargetDays.map
                    {
                        "\(age.long) ago (target: \($0) \($0 != 1 ? "days" : "day"))"
                    } ?? "\(age.long) ago"
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
                $0.action = "\(Swiftinit.API[.packageAlign])"
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
                        $0.value = "\(self.package.id)"
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
                $0.action = "\(Swiftinit.API[.packageConfig])"
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
                        $0.value = "\(self.package.id)"
                    }

                    $0[.input]
                    {
                        $0.type = "hidden"
                        $0.name = "hidden"
                        $0.value = self.package.hidden ? "false" : "true"
                    }
                }
                $0[.p]
                {
                    $0[.button] { $0.type = "submit" } = self.package.hidden
                        ? "Unhide Package"
                        : "Hide Package"
                }
            }

            $0[.form]
            {
                $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                $0.action = "\(Swiftinit.API[.packageIndexTag])"
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
                        $0.value = "\(self.package.id)"
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
                    $0[.button] { $0.type = "submit" } = "Index Package Tag (GitHub)"
                }
            }
        }
    }
}
