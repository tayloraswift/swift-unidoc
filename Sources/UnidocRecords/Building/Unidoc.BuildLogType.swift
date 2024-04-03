import BSON

extension Unidoc
{
    @frozen public
    enum BuildLogType:String, BSONDecodable, BSONEncodable, Equatable, Sendable
    {
        case swiftPackageResolution = "R"
        case swiftPackageBuild = "B"
        case swiftSymbolGraphExtract = "E"
        case ssgcDocsBuild = "D"
    }
}
extension Unidoc.BuildLogType
{
    @inlinable public
    var name:String
    {
        switch self
        {
        case .swiftPackageResolution:   "swift-package-resolution"
        case .swiftPackageBuild:        "swift-package-build"
        case .swiftSymbolGraphExtract:  "swift-symbolgraph-extract"
        case .ssgcDocsBuild:            "ssgc"
        }
    }
}
