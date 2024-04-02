extension Unidoc
{
    @frozen public
    struct BuildLogPath
    {
        public
        let package:Package
        public
        let type:BuildLogType

        @inlinable public
        init(package:Package, type:BuildLogType)
        {
            self.package = package
            self.type = type
        }
    }
}
extension Unidoc.BuildLogPath
{
    /// Same as ``description``, but with no leading slash.
    @inlinable public
    var prefix:String
    {
        //  As this is public-facing, we want it to be at least somewhat human-readable.
        "builds/\(self.package)/\(self.type.name).log"
    }
}
extension Unidoc.BuildLogPath:CustomStringConvertible
{
    @inlinable public
    var description:String { "/\(self.prefix)" }
}
