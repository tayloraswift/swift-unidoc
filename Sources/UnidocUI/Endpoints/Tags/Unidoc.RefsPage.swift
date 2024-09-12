import HTML
import Media
import Symbols
import UnixCalendar
import UnixTime
import URI

extension Unidoc
{
    struct RefsPage
    {
        private
        let package:PackageMetadata
        private
        let consumers:Paginated<ConsumersTable>
        private
        let versions:Paginated<RefsTable>
        private
        let branches:[VersionState]
        private
        let aliases:[Symbol.Package]
        private
        let buildTools:BuildTools
        private
        let builds:Paginated<CompleteBuildsTable>
        private
        let realm:RealmMetadata?
        private
        let ticket:CrawlingTicket<Package>?

        init(
            package:PackageMetadata,
            consumers:Paginated<ConsumersTable>,
            versions:Paginated<RefsTable>,
            branches:[VersionState],
            aliases:[Symbol.Package] = [],
            buildTools:BuildTools,
            builds:Paginated<CompleteBuildsTable>,
            realm:RealmMetadata? = nil,
            ticket:CrawlingTicket<Package>? = nil)
        {
            self.package = package
            self.consumers = consumers
            self.versions = versions
            self.branches = branches
            self.aliases = aliases
            self.buildTools = buildTools
            self.builds = builds
            self.realm = realm
            self.ticket = ticket
        }
    }
}
extension Unidoc.RefsPage
{
    private
    var view:Unidoc.Permissions { self.versions.table.view }
}
extension Unidoc.RefsPage:Unidoc.RenderablePage
{
    var title:String { "Tags · \(self.package.symbol)" }
}
extension Unidoc.RefsPage:Unidoc.StaticPage
{
    var location:URI { Unidoc.RefsEndpoint[self.package.symbol] }
}
extension Unidoc.RefsPage:Unidoc.ApplicationPage
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
                    $0.action = "\(Unidoc.Post[.packageConfig])"
                    $0.method = "post"

                    $0.class = "config"
                } = Unidoc.PackageMediaSettings.init(package: self.package)
            }

            self.section(tags: &$0, format: format, dormancy: dormancy)
        }
    }
}
extension Unidoc.RefsPage
{
    private
    func section(tags section:inout HTML.ContentEncoder,
        format:Unidoc.RenderFormat,
        dormancy:Duration?)
    {
        if  let repo:Unidoc.PackageRepo = self.package.repo
        {
            section[.header, { $0.class = "visual" }]
            {
                $0[.h2] = Heading.repo
                $0[.div]
                {
                    $0.class = "visibility"
                    $0.title = repo.private
                        ? "This repository is private"
                        : "This repository is public"
                } = repo.private ?  "🗝️" : "🌐"
            }

            section[.dl] = Unidoc.PackageRepoDescriptionList.init(repo: repo,
                mode: .expanded(format.locale))
        }

        section[.a]
        {
            $0.class = "area"
            $0.href = "\(Unidoc.RulesEndpoint[self.package.symbol])"
        } = "Manage contributors"

        section[.h2] = Heading.tags
        section[.table] = self.versions.table
        if  let more:URI = self.versions.next
        {
            section[.a] { $0.class = "area" ; $0.href = "\(more)" } = "Browse more tags"
        }

        if !self.branches.isEmpty
        {
            section[.h2] = Heading.branches
            section[.table] = Unidoc.RefsTable.init(package: self.package.symbol,
                rows: self.branches,
                view: self.view,
                type: .branches)
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

                if !self.view.authenticated
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

        section[.h2] = Heading.consumers

        if  self.consumers.table.rows.isEmpty
        {
            section[.p] { $0.class = "note" } = "This package has no known consumers!"
        }
        else
        {
            section[.table] = self.consumers.table
        }
        if  let more:URI = self.consumers.next
        {
            section[.a] { $0.class = "area" ; $0.href = "\(more)" } = "Browse more consumers"
        }

        section[.h2] = Heading.settings

        if !self.view.authenticated
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

                if  self.view.admin
                {
                    //  If package is hidden, we can unhide it without confirmation.
                    let confirm:Bool = !self.package.hidden
                    $0[.form]
                    {
                        $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                        $0.action = "\(Unidoc.Post[.packageConfig, confirm: confirm])"
                        $0.method = "post"
                    } = ConfigButton.init(package: self.package.id,
                        update: "hidden",
                        value: self.package.hidden ? "false" : "true",
                        label: self.package.hidden ? "unhide package" : "hide package",
                        area: false)
                }
            }

            guard
            let repo:Unidoc.PackageRepo = self.package.repo
            else
            {
                return
            }

            let timeSinceRead:DurationFormat = .init(format.time - .init(repo.crawled))

            $0[.dt] = "Repo read"
            $0[.dd] = "\(timeSinceRead) ago"

            tagging:
            if  let configurationURL:String = self.package.repoWebhook
            {
                $0[.dt] = "Webhook"
                $0[.dd]
                {
                    $0 += "active"
                    $0[.span, { $0.class = "parenthetical" }]
                    {
                        $0[.a]
                        {
                            $0.target = "_blank"
                            $0.href = "https://\(configurationURL)"
                            $0.rel = .external
                        } = "configure"
                    }
                }
            }
            else if
                let ticket:Unidoc.CrawlingTicket<Unidoc.Package> = self.ticket
            {
                $0[.dt] = "Tags read"
                $0[.dd]
                {
                    if  let last:UnixMillisecond = ticket.last
                    {
                        let timeSinceRead:DurationFormat = .init(format.time - .init(last))

                        $0 += "\(timeSinceRead) ago"
                    }
                    else
                    {
                        $0[.span] { $0.class = "placeholder" } = "never"
                    }

                    let crawlingInterval:Milliseconds? = repo.crawlingIntervalTarget(
                        dormant: dormancy,
                        hidden: self.package.hidden,
                        realm: self.package.realm)

                    $0[.span]
                    {
                        $0.class = "parenthetical"
                    } = crawlingInterval.map
                    {
                        let dynamicInterval:DurationFormat = .init($0)
                        return "target: \(dynamicInterval)"
                    }
                }

                guard self.view.editor
                else
                {
                    break tagging
                }

                let timeRemaining:DurationFormat = .init(.init(ticket.time) - format.time)

                $0[.dt] = "Tags fetch in"
                $0[.dd] = "\(timeRemaining)"
            }
        }


        if !self.view.authenticated
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
                $0.action = "\(Unidoc.Post[.packageConfig, confirm: true])"
                $0.method = "post"
            } = ConfigButton.init(package: self.package.id,
                update: "refresh",
                value: "true",
                label: "Refresh tags",
                back: self.location)
        }
        else
        {
            section[.form] = Unidoc.DisabledButton.init(label: "Refresh tags", view: self.view)
        }

        section[.h2] = Heading.builds
        section += self.buildTools

        //  All logged-in users can see the build logs. The only reason they are not totally
        //  public is to prevent crawlers from making dynamic CloudFront requests, because the
        //  CDN firewall is less effective than our apex firewall.
        if !self.builds.table.rows.isEmpty
        {
            section[.h3] = Heading.builtRecently
            section[.table] = self.builds.table
        }
        if  let more:URI = self.builds.next
        {
            section[.a] { $0.class = "area" ; $0.href = "\(more)" } = "View all builds"
        }

        section[.h3] = Heading.buildConfiguration
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

                if !self.view.authenticated
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
                            $0.action = "\(Unidoc.Post[.packageConfig, confirm: true])"
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

        guard self.view.admin
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

