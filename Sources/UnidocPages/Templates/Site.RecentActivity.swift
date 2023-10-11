import BSON
import HTML
import UnidocDB
import UnixTime
import URI

extension Site
{
    @frozen public
    struct RecentActivity
    {
        public
        let repoActivity:[UnidocDatabase.RepoActivity]

        @inlinable public
        init(repoActivity:[UnidocDatabase.RepoActivity])
        {
            self.repoActivity = repoActivity
        }
    }
}
extension Site.RecentActivity:StaticPage
{
    public
    var canonicalURI:URI? { ["_home"] }

    public
    var location:URI { ["_home"] }
}
extension Site.RecentActivity:RenderablePage
{
    public
    var title:String { "Recent Activity" }

    public
    func body(_ body:inout HTML.ContentEncoder)
    {
        body[.div]
        {
            $0[.main]
            {
                $0[.h1] = "swiftinit"

                $0[.h2] { $0.class = "feed" } = "Recent Activity"
                $0[.ol, { $0.class = "feed repo" }]
                {
                    let now:UnixInstant = .now()
                    for item:UnidocDatabase.RepoActivity in self.repoActivity
                    {
                        $0[.li]
                        {
                            let discovered:UnixInstant = .millisecond(item.id.value)
                            let age:Age<Language.EN> = .init(now - discovered)

                            $0[.p, { $0.class = "tag"}]
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
        }
    }
}
