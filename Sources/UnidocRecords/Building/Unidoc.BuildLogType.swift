import BSON

extension Unidoc
{
    @frozen public
    enum BuildLogType:String, BSONDecodable, BSONEncodable, Equatable, Sendable
    {
        /// Deprecated.
        case ssgc = "C"
        /// Deprecated.
        case ssgcDiagnostics = "D"

        case build = "B"
        case documentation = "A"
    }
}
extension Unidoc.BuildLogType
{
    @inlinable public
    var name:String
    {
        switch self
        {
        case .ssgc:             "build"
        case .ssgcDiagnostics:  "documentation"
        case .build:            "build"
        case .documentation:    "documentation"
        }
    }
}
