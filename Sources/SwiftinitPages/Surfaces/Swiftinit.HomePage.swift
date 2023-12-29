import BSON
import HTML
import UnidocDB
import UnidocRecords
import UnixTime
import URI

extension Swiftinit
{
    struct HomePage
    {
        let repo:[UnidocDatabase.RepoFeed.Activity]
        let docs:[UnidocDatabase.DocsFeed.Activity<Unidoc.VolumeMetadata>]

        init(
            repo:[UnidocDatabase.RepoFeed.Activity],
            docs:[UnidocDatabase.DocsFeed.Activity<Unidoc.VolumeMetadata>])
        {
            self.repo = repo
            self.docs = docs
        }
    }
}
extension Swiftinit.HomePage:Swiftinit.StaticPage
{
    var canonicalURI:URI? { [] }
    var location:URI { [] }
}
extension Swiftinit.HomePage:Swiftinit.RenderablePage
{
    var description:String? { "Browse recent package releases and documentation builds" }

    var title:String { "Recent Activity" }

    public
    func head(augmenting head:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        head[unsafe: .script] = format.assets.script(volumes: nil)
    }

    func body(_ body:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        //  This div centers the content.
        body[.div]
        {
            $0[.main, { $0.class = "home" }]
            {
                $0[.h1] = "swiftinit"

                $0[.div, { $0.class = "search-tool" }]
                {
                    $0[.div, { $0.class = "searchbar-container" }]
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
                    $0[.div, { $0.class = "search-results-container" }]
                    {
                        $0[.ol] { $0.id = "search-results" }
                    }
                }

                $0[.div, { $0.class = "feeds" }]
                {
                    $0[.section, { $0.class = "repo" }]
                    {
                        $0[.h2] = "Recent Activity"
                        $0[.ol]
                        {
                            let now:UnixInstant = .now()
                            for item:UnidocDatabase.RepoFeed.Activity in self.repo
                            {
                                $0[.li]
                                {
                                    let discovered:UnixInstant = .millisecond(item.id.value)
                                    let age:Age = .init(now - discovered)

                                    $0[.p, { $0.class = "edition"}]
                                    {
                                        $0[.a]
                                        {
                                            $0.href = "\(Swiftinit.Tags[item.package])"
                                        } = "\(item.package)"

                                        $0[.span] = item.refname
                                    }

                                    $0[.p] { $0.class = "age" } = age.long
                                }
                            }
                        }
                    }

                    $0[.section, { $0.class = "docs" }]
                    {
                        $0[.h2] = "Recent Docs"
                        $0[.ol]
                        {
                            let now:UnixInstant = .now()
                            for item:UnidocDatabase.DocsFeed.Activity<Unidoc.VolumeMetadata> in
                                self.docs
                            {
                                $0[.li]
                                {
                                    let discovered:UnixInstant = .millisecond(item.id.value)
                                    let age:Age = .init(now - discovered)

                                    $0[.p, { $0.class = "edition"}]
                                    {
                                        $0[.span] = "\(item.volume.symbol.package)"
                                        $0[.a]
                                        {
                                            $0.href = "\(Swiftinit.Docs[item.volume])"
                                        } = item.volume.symbol.version
                                    }

                                    $0[.p] { $0.class = "age" } = age.long
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
