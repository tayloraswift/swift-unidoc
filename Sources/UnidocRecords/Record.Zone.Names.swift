import ModuleGraphs

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

        @inlinable public
        init(package:PackageIdentifier, version:String, refname:String?)
        {
            self.package = package
            self.version = version
            self.refname = refname
        }
    }
}
