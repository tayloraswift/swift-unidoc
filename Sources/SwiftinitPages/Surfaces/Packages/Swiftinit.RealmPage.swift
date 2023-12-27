import HTML
import URI

extension Swiftinit
{
    struct RealmPage
    {
        let metadata:Unidoc.RealmMetadata
        let packages:[Unidoc.PackageOutput]
        let user:Unidoc.User?

        private
        init(metadata:Unidoc.RealmMetadata,
            packages:[Unidoc.PackageOutput],
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

        var packages:[Unidoc.PackageOutput] = output.packages
        let metadata:Unidoc.RealmMetadata = output.metadata
        let user:Unidoc.User? = (consume output).user

        packages.sort { $0.metadata.symbol < $1.metadata.symbol }

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
                for package:Unidoc.PackageOutput in self.packages
                {
                    $0[.li] = Swiftinit.PackageCard.init(package)
                }
            }
        }
    }
}
