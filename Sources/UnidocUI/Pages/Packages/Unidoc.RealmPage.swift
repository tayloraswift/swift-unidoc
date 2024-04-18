import HTML
import URI

extension Unidoc
{
    struct RealmPage
    {
        let metadata:RealmMetadata
        let packages:PackageGroups
        let user:User?

        private
        init(metadata:RealmMetadata,
            packages:PackageGroups,
            user:User?)
        {
            self.metadata = metadata
            self.packages = packages
            self.user = user
        }
    }
}
extension Unidoc.RealmPage
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
extension Unidoc.RealmPage:Unidoc.RenderablePage
{
    var title:String { "Realms · \(self.metadata.symbol)" }
}
extension Unidoc.RealmPage:Unidoc.StaticPage
{
    var location:URI { Unidoc.Realms[self.metadata.symbol] }
}
extension Unidoc.RealmPage:Unidoc.ApplicationPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
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
