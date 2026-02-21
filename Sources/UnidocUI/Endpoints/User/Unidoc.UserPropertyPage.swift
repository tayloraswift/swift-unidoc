import HTML
import Media
import URI

extension Unidoc {
    struct UserPropertyPage {
        private let user: User?
        private let name: String
        private let packages: PackageGroups
        private let id: Account

        init(user: User?, name: String, packages: PackageGroups, id: Account) {
            self.user = user
            self.name = name
            self.packages = packages
            self.id = id
        }
    }
}
extension Unidoc.UserPropertyPage: Unidoc.RenderablePage {
    var title: String { "\(self.name)’s properties" }
}
extension Unidoc.UserPropertyPage: Unidoc.StaticPage {
    var location: URI { Unidoc.UserPropertyEndpoint[self.id] }
}
extension Unidoc.UserPropertyPage: Unidoc.ApplicationPage {
    func main(_ main: inout HTML.ContentEncoder, format: Unidoc.RenderFormat) {
        main[.header, { $0.class = "hero" }] {
            $0[.h1] = self.title

            $0 += Unidoc.UserBanner.init(
                user: self.user,
                name: self.name,
                packages: self.packages.count
            )
        }
        main += self.packages
    }
}
