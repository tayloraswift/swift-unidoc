import HTML
import URI

extension Unidoc {
    struct RealmPage {
        let metadata: RealmMetadata
        let packages: PackageGroups
        let user: User?

        init(
            metadata: RealmMetadata,
            packages: PackageGroups,
            user: User?
        ) {
            self.metadata = metadata
            self.packages = packages
            self.user = user
        }
    }
}
extension Unidoc.RealmPage: Unidoc.RenderablePage {
    var title: String { "Realms · \(self.metadata.symbol)" }
}
extension Unidoc.RealmPage: Unidoc.StaticPage {
    var location: URI { Unidoc.RealmEndpoint[self.metadata.symbol] }
}
extension Unidoc.RealmPage: Unidoc.ApplicationPage {
    func main(_ main: inout HTML.ContentEncoder, format: Unidoc.RenderFormat) {
        main[.header, { $0.class = "hero" }] {
            $0[.h1] = "\(self.metadata.symbol) (realm)"
        }

        if  self.packages.isEmpty {
            main[.p] = "This realm contains no packages."
        } else {
            main += self.packages
        }
    }
}
