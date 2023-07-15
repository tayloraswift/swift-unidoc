import ModuleGraphs
import URI

extension Record.Zone
{
    @frozen public
    struct Names:Equatable, Hashable, Sendable
    {
        public
        let package:PackageIdentifier
        public
        let version:String?
        public
        let refname:String?

        @inlinable public
        init(package:PackageIdentifier, version:String?, refname:String?)
        {
            self.package = package
            self.version = version
            self.refname = refname
        }
    }
}
extension Record.Zone.Names
{
    @inlinable public static
    func += (uri:inout URI.Path, self:Self)
    {
        if  let version:String = self.version
        {
            uri.append("\(self.package)")
            uri.append("\(version):")
        }
        else
        {
            uri.append("\(self.package):")
        }
    }
}
