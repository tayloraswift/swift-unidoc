extension SSGC.PackageBuild
{
    @frozen public
    struct Logs:SSGC.DocumentationLogger
    {
        public
        var swiftPackageResolve:[UInt8]?
        public
        var swiftPackageBuild:[UInt8]?

        @inlinable public
        init()
        {
            self.swiftPackageResolve = nil
            self.swiftPackageBuild = nil
        }
    }
}
