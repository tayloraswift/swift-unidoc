import BSON

extension Unidoc.BuildLogs
{
    @frozen public
    struct Exported:OptionSet, Equatable, Sendable
    {
        public
        var rawValue:Int64

        @inlinable public
        init(rawValue:Int64)
        {
            self.rawValue = rawValue
        }
    }
}
extension Unidoc.BuildLogs.Exported
{
    @inlinable public static
    var swiftPackageResolve:Self { .init(rawValue: 1 << 0) }

    @inlinable public static
    var swiftPackageBuild:Self { .init(rawValue: 1 << 1) }

    @inlinable public static
    var ssgcDocsBuild:Self { .init(rawValue: 1 << 2) }
}
extension Unidoc.BuildLogs.Exported:BSONDecodable, BSONEncodable
{
}
