extension PackageResolutions
{
    public
    struct FormatVersionError:Error, Equatable, Sendable
    {
        public
        let version:UInt

        public
        init(unsupported version:UInt)
        {
            self.version = version
        }
    }
}
extension PackageResolutions.FormatVersionError:CustomStringConvertible
{
    public
    var description:String
    {
        "Unsupported Package.resolved format version (\(self.version))"
    }
}
