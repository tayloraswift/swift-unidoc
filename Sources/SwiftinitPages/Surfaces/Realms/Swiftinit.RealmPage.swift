import HTML
import URI

extension Swiftinit
{
    struct RealmPage
    {
        let metadata:Unidoc.RealmMetadata
        let packages:[Unidoc.PackageMetadata]
        let user:Unidoc.User?

        private
        init(metadata:Unidoc.RealmMetadata,
            packages:[Unidoc.PackageMetadata],
            user:Unidoc.User?)
        {
            self.metadata = metadata
            self.packages = packages
            self.user = user
        }
    }
}
extension Swiftinit.RealmPage
{
    init(from output:consuming Unidoc.RealmQuery.Output)
    {
        let output:Unidoc.RealmQuery.Output = output

        var packages:[Unidoc.PackageMetadata] = output.packages
        let metadata:Unidoc.RealmMetadata = output.metadata
        let user:Unidoc.User? = (consume output).user

        packages.sort { $0.symbol < $1.symbol }

        self.init(metadata: metadata, packages: packages, user: user)
    }
}
extension Swiftinit.RealmPage:Swiftinit.RenderablePage
{
    var title:String { "Realms · \(self.metadata.symbol)" }
}
extension Swiftinit.RealmPage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Realm[self.metadata.symbol] }
}
extension Swiftinit.RealmPage:Swiftinit.ApplicationPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.h1] = "\(self.metadata.symbol) (realm)"
        }

        main[.section, { $0.class = "details" }]
        {
            if  self.packages.isEmpty
            {
                $0[.p] = "This realm contains no packages."
                return
            }

            $0[.h2] = "Realm members"
            $0[.ol, { $0.class = "packages" }]
            {
                for package:Unidoc.PackageMetadata in self.packages
                {
                    $0[.li]
                    {
                        $0[.a]
                        {
                            $0.href = "\(Swiftinit.Tags[package.symbol])"
                        } = "\(package.symbol)"
                    }
                }
            }
        }
    }
}
