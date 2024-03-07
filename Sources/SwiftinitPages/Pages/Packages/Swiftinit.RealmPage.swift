import HTML
import URI

extension Swiftinit
{
    struct RealmPage
    {
        let metadata:Unidoc.RealmMetadata
        let packages:PackageGroups
        let user:Unidoc.User?

        private
        init(metadata:Unidoc.RealmMetadata,
            packages:PackageGroups,
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
        //  5.9 compiler bug :(
        let packages:[Unidoc.PackageOutput] = output.packages
        let metadata:Unidoc.RealmMetadata = output.metadata
        let user:Unidoc.User? = (consume output).user

        self.init(metadata: metadata,
            packages: .init(organizing: packages, heading: .realm),
            user: user)
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
            }
            else
            {
                $0 += self.packages
            }
        }
    }
}
