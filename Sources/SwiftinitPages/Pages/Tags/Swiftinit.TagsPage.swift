import BSON
import Durations
import GitHubAPI
import HTML
import Media
import Symbols
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
        let aliases:[Symbol.Package]
        private
        let realm:Unidoc.RealmMetadata?
        private
        let table:TagsTable
        private
        let shown:Unidoc.VersionsPredicate

        init(package:Unidoc.PackageMetadata,
            aliases:[Symbol.Package] = [],
            realm:Unidoc.RealmMetadata? = nil,
            table:TagsTable,
            shown:Unidoc.VersionsPredicate)
        {
            self.package = package
            self.aliases = aliases
            self.realm = realm
            self.table = table
            self.shown = shown
        }
    }
}
extension Swiftinit.TagsPage
{
    private
    var view:Swiftinit.ViewMode { self.table.view }
}
extension Swiftinit.TagsPage:Swiftinit.RenderablePage
{
    var title:String { "Git Tags · \(self.package.symbol)" }
}
extension Swiftinit.TagsPage:Swiftinit.StaticPage
{
    var location:URI
    {
        switch self.shown
        {
        case .none:
            Swiftinit.Tags[self.package.symbol]

        case .tags(_, page: let index, beta: let beta):
            Swiftinit.Tags[self.package.symbol, page: index, beta: beta]
        }
    }
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
            switch self.shown
            {
            case .none:
                self.section(tags: &$0, now: now)

            case .tags(limit: _, page: let index, beta: let beta):
                self.section(tags: &$0, page: index, beta: beta)
            }
        }
    }
}
extension Swiftinit.TagsPage
{
    private
    func section(tags section:inout HTML.ContentEncoder, page:Int, beta:Bool)
    {
        section[.h2] = beta ? Heading.prereleases : Heading.releases

        section[.nav, { $0.class = "pagniator" }]
        {
            if  page > 0
            {
                $0[.a]
                {
                    $0.href = """
                    \(Swiftinit.Tags[self.package.symbol, page: page - 1, beta: beta])
                    """
                } = "◀"
            }
            else
            {
                $0[.span] = "◀"
            }

            if  self.table.more
            {
                $0[.a]
                {
                    $0.href = """
                    \(Swiftinit.Tags[self.package.symbol, page: page + 1, beta: beta])
                    """
                } = "▶"
            }
            else
            {
                $0[.span] = "▶"
            }
        }

        section[.table] { $0.class = "tags" } = self.table

        section[.div, { $0.class = "more" }]
        {
            $0[.a]
            {
                $0.class = "button"
                $0.href = "\(Swiftinit.Tags[self.package.symbol])"
            } = "Back to repo details"
        }
    }

    private
    func section(tags section:inout HTML.ContentEncoder, now:UnixInstant)
    {
        if  let repo:Unidoc.PackageRepo = self.package.repo
        {
            section[.h2] = "Package Repository"

            section[.dl]
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

        section[.h2] = Heading.tags

        section[.table] { $0.class = "tags" } = self.table

        if  self.table.more
        {
            section[.div, { $0.class = "more" }]
            {
                $0[.a]
                {
                    $0.class = "button"
                    $0.href = "\(Swiftinit.Tags[self.package.symbol, page: 0])"
                } = "Browse more tags"
            }
        }

        section[.h2] = Heading.settings

        section[.dl]
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
            $0[.dd]
            {
                $0 += self.package.hidden ? "yes" : "no"

                guard case .maintainer = self.view
                else
                {
                    return
                }

                $0[.form]
                {
                    $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                    $0.action = "\(Swiftinit.API[.packageConfig])"
                    $0.method = "post"
                } = ConfigButton.init(package: self.package.id,
                    update: "hidden",
                    value: self.package.hidden ? "false" : "true",
                    label: self.package.hidden ? "Unhide Package" : "Hide Package")
            }

            if  let crawled:BSON.Millisecond = self.package.repo?.crawled
            {
                let crawled:UnixInstant = .millisecond(crawled.value)
                let age:Swiftinit.Age = .init(now - crawled)

                $0[.dt] = "Repo read"
                $0[.dd] = age.long
            }
            if  let fetched:BSON.Millisecond = self.package.repo?.fetched
            {
                let fetched:UnixInstant = .millisecond(fetched.value)
                let age:Swiftinit.Age = .init(now - fetched)

                $0[.dt] = "Tags read"
                $0[.dd]
                {
                    $0 += age.long

                    $0[.span]
                    {
                        $0.class = "parenthetical"
                    } = self.package.crawlingIntervalTarget.map
                    {
                        let interval:Swiftinit.Age = .init(.milliseconds($0))
                        if  case .maintainer = self.view,
                            let expires:BSON.Millisecond = self.package.repo?.expires
                        {
                            let expires:UnixInstant = .millisecond(expires.value)

                            return """
                            target: \(interval.short), \
                            expires: \(expires.timestamp?.http ?? "never")
                            """
                        }
                        else
                        {
                            return """
                            target: \(interval.short)
                            """
                        }
                    }
                }
            }
        }

        section[.h3] = "Names and aliases"

        section[.dl, { $0.class = "aliases" }]
        {
            for symbol:Symbol.Package in self.aliases
            {
                $0[.dt] = "\(symbol)"

                if  symbol == self.package.symbol
                {
                    $0[.dd]
                    {
                        $0[.span] { $0.class = "placeholder" } = "current name"
                    }
                }
                else if case .maintainer = self.view
                {
                    $0[.dd]
                    {
                        $0[.form]
                        {
                            $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                            $0.action = "\(Swiftinit.API[.packageConfig])"
                            $0.method = "post"
                        } = ConfigButton.init(package: self.package.id,
                            update: "symbol",
                            value: "\(symbol)",
                            label: "Rename package")
                    }
                }
                else
                {
                    $0[.dd]
                }
            }
        }

        guard case .maintainer = self.view
        else
        {
            return
        }

        section[.form]
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

                    $0[.span] = "Create realm"
                }
            }
            $0[.p]
            {
                $0[.button] { $0.type = "submit" } = "Transfer package"
            }
        }

        section[.form]
        {
            $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
            $0.action = "\(Swiftinit.API[.packageAlias])"
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
                    $0.name = "alias"
                    $0.placeholder = "new name"
                }
            }
            $0[.p]
            {
                $0[.button] { $0.type = "submit" } = "Alias package"
            }
        }

        section[.form]
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
                $0[.button] { $0.type = "submit" } = "Index package tag (GitHub)"
            }
        }
    }
}
