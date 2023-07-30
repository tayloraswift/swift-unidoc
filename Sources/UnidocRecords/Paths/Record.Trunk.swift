import ModuleGraphs

extension Record
{
    @frozen public
    struct Trunk:Equatable, Hashable, Sendable
    {
        public
        let package:PackageIdentifier
        public
        let version:String
        public
        let refname:String?
        public
        let display:String?
        public
        let github:String?
        public
        let latest:Bool

        @inlinable public
        init(package:PackageIdentifier,
            version:String,
            refname:String?,
            display:String?,
            github:String?,
            latest:Bool)
        {
            self.package = package
            self.version = version
            self.refname = refname
            self.display = display
            self.github = github
            self.latest = latest
        }
    }
}
