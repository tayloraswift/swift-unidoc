import BSON

extension Unidoc
{
    @frozen public
    enum BuildLogType:String, BSONDecodable, BSONEncodable, Equatable, Sendable
    {
        //  Deprecated.
        case _swiftPackageResolution = "R"
        case _swiftPackageBuild = "B"
        case _swiftSymbolGraphExtract = "E"

        case ssgc = "C"
        case ssgcDiagnostics = "D"
    }
}
extension Unidoc.BuildLogType
{
    @inlinable public
    var name:String
    {
        switch self
        {
        case ._swiftPackageResolution:      "swift-package-resolution"
        case ._swiftPackageBuild:           "swift-package-build"
        case ._swiftSymbolGraphExtract:     "swift-symbolgraph-extract"
        case .ssgc:                         "ssgc"
        case .ssgcDiagnostics:              "ssgc-diagnostics"
        }
    }
}
