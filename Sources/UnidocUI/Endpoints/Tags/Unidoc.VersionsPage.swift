import Durations
import BSON
import HTML
import Media
import Symbols
import UnixTime
import URI

extension Unidoc
{
    struct VersionsPage
    {
        private
        let versions:RefsTable
        private
        let branches:[VersionState]
        private
        let package:PackageMetadata
        private
        let aliases:[Symbol.Package]
        private
        let build:BuildMetadata?
        private
        let realm:RealmMetadata?
        private
        let more:Bool

        init(
            versions:RefsTable,
            branches:[VersionState],
            package:PackageMetadata,
            aliases:[Symbol.Package] = [],
            build:BuildMetadata? = nil,
            realm:RealmMetadata? = nil,
            more:Bool)
        {
            self.versions = versions
            self.branches = branches
            self.package = package
            self.aliases = aliases
            self.build = build
            self.realm = realm
            self.more = more
        }
    }
}
extension Unidoc.VersionsPage
{
    private
    var view:Unidoc.Permissions { self.versions.view }
}
extension Unidoc.VersionsPage:Unidoc.RenderablePage
{
    var title:String { "Tags · \(self.package.symbol)" }
}
extension Unidoc.VersionsPage:Unidoc.StaticPage
{
    var location:URI { Unidoc.TagsEndpoint[self.package.symbol] }
}
extension Unidoc.VersionsPage:Unidoc.ApplicationPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.h1] = "\(self.package.symbol)"

            guard
            let repo:Unidoc.PackageRepo = self.package.repo
            else
            {
                return
            }

            $0[.p] = repo.origin.about
            $0[.p] { $0.class = "chyron" } = repo.chyron(now: format.time)
        }

        let dormancy:Duration? = self.package.repo?.dormant(by: format.time)
        if  let time:Duration = dormancy
        {
            /// Sure, we are ignoring leap years here, but no one will notice.
            let years:Int = .init(time / .seconds(60 * 60 * 24 * 365))

            main[.section, { $0.class = "notice dormant" }]
            {
                $0[.p] = "This package has been dormant for over \(years) years!"
            }
        }

        main[.section, { $0.class = "details" }]
        {
            if  case .localhost = format.server
            {
                $0[.h2] = "Local preview settings"
                $0[.form]
                {
                    $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                    $0.action = "\(Unidoc.Post[.packageConfig, really: true])"
                    $0.method = "post"

                    $0.class = "config"
                } = Unidoc.PackageMediaSettings.init(package: self.package)
            }

            self.section(tags: &$0, now: format.time, dormancy: dormancy)
        }
    }
}
extension Unidoc.VersionsPage
{
    private
    func section(tags section:inout HTML.ContentEncoder, now:UnixInstant, dormancy:Duration?)
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
                    $0[.dd]
                    {
                        $0[.a]
                        {
                            $0.href = "\(Unidoc.RulesEndpoint[self.package.symbol])"
                        } = origin.owner
                    }

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
                            $0.href = "\(Unidoc.PackagesCreatedEndpoint[created])"
                        } = "\(created.month(.en)) \(created.day), \(created.year)"
                    }
                }
            }
        }

        if  let account:Unidoc.Account = self.package.repo?.account
        {
            section[.a]
            {
                $0.class = "area"
                $0.href = "\(Unidoc.UserPropertyEndpoint[account])"
            } = "More packages by this author"
        }

        section[.h2] = Heading.tags

        section[.table] { $0.class = "tags" } = self.versions

        if  self.more
        {
            section[.a]
            {
                $0.class = "area"
                $0.href = "\(Unidoc.TagsEndpoint[self.package.symbol, .release, page: 0])"
            } = "Browse more tags"
        }

        if !self.branches.isEmpty
        {
            section[.h2] = Heading.branches
            section[.table]
            {
                $0.class = "tags"
            } = Unidoc.RefsTable.init(package: self.package.symbol,
                rows: self.branches,
                view: self.view,
                type: .branches)
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
            $0[.dt] = "Package ID"
            $0[.dd] = "\(self.package.id)"

            $0[.dt] = "Realm"
            $0[.dd]
            {
                if  let realm:Unidoc.RealmMetadata = self.realm
                {
                    $0[.a]
                    {
                        $0.href = "\(Unidoc.RealmEndpoint[realm.symbol])"
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

            $0[.dt] = "Hidden?"
            $0[.dd]
            {
                $0 += self.package.hidden ? "yes" : "no"

                if  case .administratrix? = self.view.global
                {
                    //  If package is hidden, we can unhide it without confirmation.
                    let really:Bool = self.package.hidden
                    $0[.form]
                    {
                        $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                        $0.action = "\(Unidoc.Post[.packageConfig, really: really])"
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
            if  let repo:Unidoc.PackageRepo = self.package.repo,
                let fetched:BSON.Millisecond = repo.fetched
            {
                let dynamicAge:Duration.DynamicFormat = .init(
                    truncating: now - .millisecond(fetched.value))

                $0[.dt] = "Tags read"
                $0[.dd]
                {
                    $0 += "\(dynamicAge) ago"

                    let crawlingInterval:Milliseconds? = repo.crawlingIntervalTarget(
                        dormant: dormancy,
                        hidden: self.package.hidden,
                        realm: self.package.realm)

                    $0[.span]
                    {
                        $0.class = "parenthetical"
                    } = crawlingInterval.map
                    {
                        let dynamicInterval:Duration.DynamicFormat = .init(
                            truncating: .milliseconds($0))
                        return "target: \(dynamicInterval)"
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


        if case nil = self.view.global
        {
            section[.form]
            {
                $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                $0.action = "\(Unidoc.ServerRoot.login)"
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
        else if self.view.editor
        {
            section[.form]
            {
                $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                $0.action = "\(Unidoc.Post[.packageConfig, really: false])"
                $0.method = "post"
            } = ConfigButton.init(package: self.package.id,
                update: "refresh",
                value: "true",
                label: "Refresh tags")
        }
        else
        {
            section[.form] = Unidoc.DisabledButton.init(label: "Refresh tags", view: self.view)
        }

        section[.div]
        {
            $0.class = "build-pipeline"
        } = BuildTools.init(package: self.package,
            build: self.build,
            view: self.view,
            back: self.location)

        //  All logged-in users can see the build logs. The only reason they are not totally
        //  public is to prevent crawlers from making dynamic CloudFront requests, because the
        //  CDN firewall is less effective than our apex firewall.
        if  case _? = self.view.global,
            let build:Unidoc.BuildMetadata = self.build,
            !build.logs.isEmpty
        {
            section[.h3] = "Build logs"
            section[.ol]
            {
                $0.class = "build-logs"
            }
                content:
            {
                for log:Unidoc.BuildLogType in build.logs
                {
                    $0[.li]
                    {
                        //  We never persist logs anywhere except in S3, where they are
                        //  served through CloudFront. Therefore, we can safely hardcode
                        //  the URL here.
                        let path:Unidoc.BuildLogPath = .init(package: build.id, type: log)

                        $0[.a]
                        {
                            $0.target = "_blank"
                            $0.href = "https://static.swiftinit.org\(path)"
                            $0.rel = .external
                        } = log.name
                    }
                }
            }
        }

        section[.h3] = Heading.importRefs
        section[.form]
        {
            $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
            $0.action = "\(Unidoc.Post[.packageIndex])"
            $0.method = "post"

            $0.class = "config"
        }
            content:
        {
            $0[.dl]
            {
                $0[.dt] = "Branch name"
                $0[.dd]
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
                        $0.name = "ref"
                        $0.required = true
                        $0.readonly = !self.view.editor

                        $0.placeholder = "master"
                        $0.pattern = #"^[a-zA-Z0-9_\-\.\/]+$"#
                    }
                }
            }

            $0[.button]
            {
                $0.class = "area"
                $0.type = "submit"

                if  case nil = self.view.global
                {
                    $0.disabled = true
                    $0.title = "You are not logged in!"
                }
                else if !self.view.editor
                {
                    $0.disabled = true
                    $0.title = "You are not an editor for this package!"
                }
            } = "Import ref"
        }

        section[.h3] = "Build configuration"
        section[.form]
        {
            $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
            $0.action = "\(Unidoc.Post[.packageConfig])"
            $0.method = "post"

            $0.class = "config"
        }
            content:
        {
            $0[.dl]
            {
                $0[.dt] = "Platform preference"
                $0[.dd]
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
                        $0.name = "platform-preference"
                        $0.required = true
                        $0.readonly = !self.view.editor

                        $0.placeholder = "aarch64-unknown-linux-gnu"
                        $0.pattern = #"^[a-zA-Z0-9_\-\.]+$"#
                        $0.value = self.package.platformPreference?.description
                    }
                }
            }

            $0[.button]
            {
                $0.class = "area"
                $0.type = "submit"

                if  case nil = self.view.global
                {
                    $0.disabled = true
                    $0.title = "You are not logged in!"
                }
                else if !self.view.editor
                {
                    $0.disabled = true
                    $0.title = "You are not an editor for this package!"
                }
            } = "Update configuration"
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
                            $0.action = "\(Unidoc.Post[.packageConfig, really: false])"
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
            $0.action = "\(Unidoc.Post[.packageAlign])"
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
            $0.action = "\(Unidoc.Post[.packageAlias])"
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
    }
}

