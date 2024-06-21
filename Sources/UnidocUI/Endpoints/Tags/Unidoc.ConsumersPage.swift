import HTML
import Symbols
import UnixTime
import URI

extension Unidoc
{
    struct ConsumersPage
    {
        private
        let package:PackageMetadata
        private
        let page:Paginated<ConsumersTable>

        init(package:PackageMetadata, table page:Paginated<ConsumersTable>)
        {
            self.package = package
            self.page = page
        }
    }
}
extension Unidoc.ConsumersPage:Unidoc.RenderablePage
{
    var title:String { "Consumers · \(self.package.symbol)" }
}
extension Unidoc.ConsumersPage:Unidoc.StaticPage
{
    var location:URI
    {
        Unidoc.ConsumersEndpoint[self.package.symbol, page: self.page.index]
    }
}
extension Unidoc.ConsumersPage:Unidoc.ApplicationPage
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

        main[.section, { $0.class = "details" }]
        {
            $0 += self.page

            $0[.a]
            {
                $0.class = "area"
                $0.href = "\(Unidoc.RefsEndpoint[self.package.symbol])"
            } = "Back to repo details"
        }
    }
}

