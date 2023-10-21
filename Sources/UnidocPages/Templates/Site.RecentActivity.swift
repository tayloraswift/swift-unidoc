import BSON
import HTML
import UnidocDB
import UnidocRecords
import UnixTime
import URI

extension Site
{
    struct RecentActivity
    {
        let repo:[UnidocDatabase.RepoActivity]
        let docs:[UnidocDatabase.DocsActivity<Volume.Meta>]

        init(
            repo:[UnidocDatabase.RepoActivity],
            docs:[UnidocDatabase.DocsActivity<Volume.Meta>])
        {
            self.repo = repo
            self.docs = docs
        }
    }
}
extension Site.RecentActivity:StaticPage
{
    var canonicalURI:URI? { [] }
    var location:URI { [] }
}
extension Site.RecentActivity:RenderablePage
{
    var description:String? { "Browse recent package releases and documentation builds" }

    var title:String { "Recent Activity" }

    public
    func head(augmenting head:inout HTML.ContentEncoder, assets:StaticAssets)
    {
        head[unsafe: .script] = "const volumes = [];"
    }

    func body(_ body:inout HTML.ContentEncoder)
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
                            for item:UnidocDatabase.RepoActivity in self.repo
                            {
                                $0[.li]
                                {
                                    let discovered:UnixInstant = .millisecond(item.id.value)
                                    let age:Age<Language.EN> = .init(now - discovered)

                                    $0[.p, { $0.class = "edition"}]
                                    {
                                        $0[.a]
                                        {
                                            $0.href = "\(Site.Tags[item.package])"
                                        } = "\(item.package)"

                                        $0[.span] = item.refname
                                    }

                                    $0[.p] { $0.class = "age" } = "\(age)"
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
                            for item:UnidocDatabase.DocsActivity<Volume.Meta> in self.docs
                            {
                                $0[.li]
                                {
                                    let discovered:UnixInstant = .millisecond(item.id.value)
                                    let age:Age<Language.EN> = .init(now - discovered)

                                    $0[.p, { $0.class = "edition"}]
                                    {
                                        $0[.span] = "\(item.volume.symbol.package)"
                                        $0[.a]
                                        {
                                            $0.href = "\(Site.Docs[item.volume])"
                                        } = item.volume.symbol.version
                                    }

                                    $0[.p] { $0.class = "age" } = "\(age)"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
