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
        let version:String
        public
        let refname:String?
        public
        let latest:Bool

        @inlinable public
        init(package:PackageIdentifier, version:String, refname:String?, latest:Bool)
        {
            self.package = package
            self.version = version
            self.refname = refname
            self.latest = latest
        }
    }
}
extension Record.Zone.Names
{
    @inlinable public static
    func += (uri:inout URI.Path, self:Self)
    {
        if  self.latest
        {
            uri.append("\(self.package):")
        }
        else
        {
            uri.append("\(self.package)")
            uri.append("\(self.version):")
        }
    }
}
