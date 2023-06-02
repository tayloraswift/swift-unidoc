extension DocumentationDatabase
{
    @frozen public
    struct ObjectReceipt:Equatable, Hashable, Sendable
    {
        public
        let package:Int32
        public
        let version:Int32
        public
        let overwritten:Bool

        @inlinable public
        init(overwritten:Bool, package:Int32, version:Int32)
        {
            self.overwritten = overwritten
            self.package = package
            self.version = version
        }
    }
}
