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
        let build:Unidoc.BuildMetadata?
        private
        let realm:Unidoc.RealmMetadata?
        private
        let table:TagsTable
        private
        let shown:Unidoc.VersionsQuery.Predicate

        init(package:Unidoc.PackageMetadata,
            aliases:[Symbol.Package] = [],
            build:Unidoc.BuildMetadata? = nil,
            realm:Unidoc.RealmMetadata? = nil,
            table:TagsTable,
            shown:Unidoc.VersionsQuery.Predicate)
        {
            self.package = package
            self.aliases = aliases
            self.build = build
            self.realm = realm
            self.table = table
            self.shown = shown
        }
    }
}
extension Swiftinit.TagsPage
{
    private
    var view:Swiftinit.Permissions { self.table.view }
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

        case .tags(_, page: let index, series: let series):
            Swiftinit.Tags[self.package.symbol, page: index, beta: series == .prerelease]
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

            case .tags(limit: _, page: let index, series: let series):
                self.section(tags: &$0, page: index, beta: series == .prerelease)
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

        section[.nav, { $0.class = "paginator" }]
        {
            if  page > 0
            {
                $0[.a]
                {
                    $0.href = """
                    \(Swiftinit.Tags[self.package.symbol, page: page - 1, beta: beta])
                    """
                } = "prev"
            }
            else
            {
                $0[.span] = "prev"
            }

            if  self.table.more
            {
                $0[.a]
                {
                    $0.href = """
                    \(Swiftinit.Tags[self.package.symbol, page: page + 1, beta: beta])
                    """
                } = "next"
            }
            else
            {
                $0[.span] = "next"
            }
        }

        section[.table] { $0.class = "tags" } = self.table

        section[.a]
        {
            $0.class = "area"
            $0.href = "\(Swiftinit.Tags[self.package.symbol])"
        } = "Back to repo details"
    }

    private
    func section(tags section:inout HTML.ContentEncoder, now:UnixInstant)
    {
        if  let repo:Unidoc.PackageRepo = self.package.repo
        {
            section[.h2] = "Package repository"

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
            section[.a]
            {
                $0.class = "area"
                $0.href = "\(Swiftinit.Tags[self.package.symbol, page: 0])"
            } = "Browse more tags"
        }

        section[.h2] = Heading.settings

        if  case nil = self.view.global
        {
            section[.p] { $0.class = "note" } = "You are not logged in!"
        }
        else
        {
            section[.p] { $0.class = "note" } = switch self.view.rights
            {
            case .reader:   nil as String?
            case .editor:   "You are an editor of this package!"
            case .owner:    "You are the owner of this package!"
            }
        }

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

                if  case .administratrix? = self.view.global
                {
                    $0[.form]
                    {
                        $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                        $0.action = "\(Swiftinit.API[.packageConfig, really: false])"
                        $0.method = "post"
                    } = ConfigButton.init(package: self.package.id,
                        update: "hidden",
                        value: self.package.hidden ? "false" : "true",
                        label: self.package.hidden ? "unhide package" : "hide package",
                        area: false)
                }
            }

            if  let crawled:BSON.Millisecond = self.package.repo?.crawled
            {
                let dynamicAge:Duration.DynamicFormat = .init(
                    truncating: now - .millisecond(crawled.value))

                $0[.dt] = "Repo read"
                $0[.dd] = "\(dynamicAge) ago"
            }
            if  let fetched:BSON.Millisecond = self.package.repo?.fetched
            {
                let dynamicAge:Duration.DynamicFormat = .init(
                    truncating: now - .millisecond(fetched.value))

                $0[.dt] = "Tags read"
                $0[.dd]
                {
                    $0 += "\(dynamicAge) ago"

                    $0[.span]
                    {
                        $0.class = "parenthetical"
                    } = self.package.crawlingIntervalTarget.map
                    {
                        let interval:Duration.DynamicFormat = .init(
                            truncating: .milliseconds($0))
                        return "target: \(interval)"
                    }
                }
            }
            if  self.view.editor,
                let expires:BSON.Millisecond = self.package.repo?.expires
            {
                let dynamicInterval:Duration.DynamicFormat = .init(
                    truncating: .millisecond(expires.value) - now)

                $0[.dt] = "Tags fetch in"
                $0[.dd] = "\(dynamicInterval)"
            }
        }

        if  self.view.editor
        {
            section[.form]
            {
                $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                $0.action = "\(Swiftinit.API[.packageConfig, really: false])"
                $0.method = "post"
            } = ConfigButton.init(package: self.package.id,
                update: "refresh",
                value: "true",
                label: "Refresh tags")
        }
        else if case nil = self.view.global
        {
            section[.form]
            {
                $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                $0.action = "\(Swiftinit.Root.login)"
                $0.method = "post"
            }
                content:
            {
                $0[.input]
                {
                    $0.type = "hidden"
                    $0.name = "from"
                    $0.value = "\(self.location)"
                }

                $0[.button] { $0.class = "area" ; $0.type = "submit" } = "Log in"
            }
        }

        if  self.view.editor
        {
            section[.div, { $0.class = "build-pipeline" }]
            {
                if  case _? = self.build?.progress
                {
                    $0[.div]
                    {
                        $0.title = "You cannot cancel a build that has already started!"
                    } = "Cancel build"
                    $0[.div] = "Queued"
                    $0[.div] { $0.class = "phase" } = "Started"
                }
                else if
                    case _? = self.build?.request
                {
                    $0[.form]
                    {
                        $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                        $0.action = "\(Swiftinit.API[.packageConfig, really: false])"
                        $0.method = "post"
                    } = ConfigButton.init(package: self.package.id,
                        update: "build",
                        value: "cancel",
                        label: "Cancel build",
                        from: self.location)

                    $0[.div] { $0.class = "phase" } = "Queued"
                    $0[.div]
                }
                else
                {
                    $0[.form]
                    {
                        $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                        $0.action = "\(Swiftinit.API[.packageConfig, really: false])"
                        $0.method = "post"
                    } = ConfigButton.init(package: self.package.id,
                        update: "build",
                        value: "rebuild",
                        label: "Request build",
                        from: self.location)

                    $0[.div]
                    $0[.div]
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
                else if self.view.owner
                {
                    $0[.dd]
                    {
                        $0[.form]
                        {
                            $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                            $0.action = "\(Swiftinit.API[.packageConfig, really: false])"
                            $0.method = "post"
                        } = ConfigButton.init(package: self.package.id,
                            update: "symbol",
                            value: "\(symbol)",
                            label: "rename package",
                            area: false)
                    }
                }
                else
                {
                    $0[.dd]
                }
            }
        }

        guard case .administratrix? = self.view.global
        else
        {
            return
        }

        section[.h2] = Heading.settingsAdmin

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
