import HTML
import URI

extension Swiftinit
{
    struct StatsThumbnail
    {
        private
        let target:URI
        private
        let census:Unidoc.Census
        private
        let domain:String
        private
        let title:String

        init(target:URI, census:Unidoc.Census, domain:String, title:String)
        {
            self.target = target
            self.census = census
            self.domain = domain
            self.title = title
        }
    }
}
extension Swiftinit.StatsThumbnail:HTML.OutputStreamable
{
    static
    func += (div:inout HTML.ContentEncoder, self:Self)
    {
        let url:String = "\(self.target)"

        div[.div, { $0.class = "charts" }]
        {
            $0[.div]
            {
                $0[.p]
                {
                    let target:Swiftinit.StatsHeading = .interfaceBreakdown
                    $0[.a] { $0.href = "\(url)#\(target.id)" } = "Declarations"
                }

                $0[.figure]
                {
                    $0.class = "chart decl"
                } = self.census.unweighted.decls.pie
                {
                    """
                    \($1) percent of the declarations in \(self.domain) are \($0.name)
                    """
                }
            }

            $0[.div]
            {
                $0[.p]
                {
                    let target:Swiftinit.StatsHeading = .documentationCoverage
                    $0[.a] { $0.href = "\(url)#\(target.id)" } = "Coverage"
                }

                $0[.figure]
                {
                    $0.class = "chart coverage"
                } = self.census.unweighted.coverage.pie
                {
                    """
                    \($1) percent of the declarations in \(self.domain) are \($0.name)
                    """
                }
            }
        }

        div[.a] { $0.href = url } = self.title
    }
}
