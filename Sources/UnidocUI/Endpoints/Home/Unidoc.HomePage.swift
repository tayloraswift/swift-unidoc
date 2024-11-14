import BSON
import HTML
import UnidocDB
import UnidocRecords
import UnixTime
import URI

extension Unidoc
{
    struct HomePage
    {
        let repo:[DB.RepoFeed.Activity]
        let docs:[DB.DocsFeed.Activity<VolumeMetadata>]

        init(
            repo:[DB.RepoFeed.Activity],
            docs:[DB.DocsFeed.Activity<VolumeMetadata>])
        {
            self.repo = repo
            self.docs = docs
        }
    }
}
extension Unidoc.HomePage:Unidoc.StaticPage
{
    var canonicalURI:URI? { [] }
    var location:URI { [] }
}
extension Unidoc.HomePage:Unidoc.RenderablePage
{
    var description:String? { "Browse recent package releases and documentation builds" }

    var title:String { "Recent activity" }

    public
    func head(augmenting head:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        head[unsafe: .script] = format.assets.script(volumes: nil)
    }

    func body(_ body:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        //  The `div` centers the `main`
        body[.div, { $0.id = "home" }]
        {
            $0[.main]
            {
                $0[.h1] = format.sitename

                $0[.div, { $0.class = "search" }]
                {
                    $0[.div]
                    {
                        $0[.div]
                        {
                            $0.class = "searchbar"
                            $0.title = """
                            Search for any package on Swiftinit!

                            Shortcut: /
                            """
                        }
                            content:
                        {
                            $0[.form, { $0.id = "search" ; $0.role = "search" }]
                            {
                                $0[.input]
                                {
                                    $0.id = "search-input"
                                    $0.type = "search"
                                    $0.placeholder = "search packages"
                                    $0.autocomplete = "off"
                                }
                            }
                        }
                    }
                    $0[.div]
                    {
                        $0[.ol] { $0.id = "search-results" }
                    }
                }

                $0[.nav]
                {
                    $0[.ul]
                    {
                        $0[.li]
                        {
                            $0[.a]
                            {
                                $0.href = "/docs/swift"
                            } = "Standard library docs"
                        }

                        $0[.li]
                        {
                            $0[.a]
                            {
                                $0.href = "/docs/swift-package-manager/packagedescription"
                            } = "SwiftPM PackageDescription"
                        }

                        $0[.li]
                        {
                            $0[.a]
                            {
                                $0.href = "/docs/swift-syntax/swiftsyntax"
                            } = "SwiftSyntax docs"
                        }

                        $0[.li]
                        {
                            $0[.a]
                            {
                                $0.href = "/help/self-serve"
                            } = "Self-serve help"
                        }
                    }
                }

                $0[.div, { $0.class = "feeds" }]
                {
                    $0[.section, { $0.class = "repo" }]
                    {
                        $0[.h2] = "Recent activity"
                        $0[.ol]
                        {
                            for item:Unidoc.DB.RepoFeed.Activity in self.repo
                            {
                                $0[.li]
                                {
                                    let age:Duration = format.time - .init(item.id)
                                    let ageFormat:DurationFormat = .init(age)

                                    $0[.p, { $0.class = "edition"}]
                                    {
                                        $0[.a]
                                        {
                                            $0.href = "\(Unidoc.RefsEndpoint[item.package])"
                                        } = "\(item.package)"

                                        $0[.span] = item.refname
                                    }

                                    $0[.p] { $0.class = "age" } = ageFormat.unit != .seconds
                                        ? "\(ageFormat) ago"
                                        : "just now"
                                }
                            }
                        }
                    }

                    $0[.section, { $0.class = "docs" }]
                    {
                        $0[.h2] = "Recent docs"
                        $0[.ol]
                        {
                            for item:Unidoc.DB.DocsFeed.Activity<Unidoc.VolumeMetadata> in
                                self.docs
                            {
                                $0[.li]
                                {
                                    let age:Duration = format.time - .init(item.id)
                                    let ageFormat:DurationFormat = .init(age)

                                    $0[.p, { $0.class = "edition"}]
                                    {
                                        $0[.span] = "\(item.volume.symbol.package)"
                                        $0[.a]
                                        {
                                            $0.href = "\(Unidoc.DocsEndpoint[item.volume])"
                                        } = item.volume.symbol.version
                                    }

                                    $0[.p] { $0.class = "age" } = ageFormat.unit != .seconds
                                        ? "\(ageFormat) ago"
                                        : "just now"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
