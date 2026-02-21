import HTML
import Symbols
import UnixTime
import URI

extension Unidoc {
    struct PackageCursorPage<Table> where Table: IterableTable & HTML.OutputStreamable {
        let location: URI

        private let package: PackageMetadata
        private let content: Paginated<Table>
        private let name: String

        init(location: URI, package: PackageMetadata, content: Paginated<Table>, name: String) {
            self.location = location
            self.package = package
            self.content = content
            self.name = name
        }
    }
}
extension Unidoc.PackageCursorPage: Unidoc.RenderablePage {
    var title: String { "\(self.name) · \(self.package.symbol)" }
}
extension Unidoc.PackageCursorPage: Unidoc.StaticPage {
}
extension Unidoc.PackageCursorPage: Unidoc.ApplicationPage {
    func main(_ main: inout HTML.ContentEncoder, format: Unidoc.RenderFormat) {
        main[.header, { $0.class = "hero" }] {
            $0[.h1] = "\(self.package.symbol)"

            guard
            let repo: Unidoc.PackageRepo = self.package.repo else {
                return
            }

            $0[.p] = repo.origin.about
            $0[.div] { $0.class = "chyron" } = repo.chyron(now: format.time)
        }

        main[.div] { $0.class = "paginated" } = self.content

        main[.footer] {
            $0[.a] {
                $0.class = "region"
                $0.href = "\(Unidoc.RefsEndpoint[self.package.symbol])"
            } = "Back to repo details"
        }
    }
}
