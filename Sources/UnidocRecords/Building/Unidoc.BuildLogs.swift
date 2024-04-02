extension Unidoc
{
    @frozen public
    struct BuildLogs:Equatable, Sendable
    {
        public
        var swiftPackageResolve:TextStorage.Compressed?
        public
        var swiftPackageBuild:TextStorage.Compressed?
        public
        var ssgcDocsBuild:TextStorage.Compressed?

        @inlinable public
        init(
            swiftPackageResolve:TextStorage.Compressed? = nil,
            swiftPackageBuild:TextStorage.Compressed? = nil,
            ssgcDocsBuild:TextStorage.Compressed? = nil)
        {
            self.swiftPackageResolve = swiftPackageResolve
            self.swiftPackageBuild = swiftPackageBuild
            self.ssgcDocsBuild = ssgcDocsBuild
        }
    }
}
