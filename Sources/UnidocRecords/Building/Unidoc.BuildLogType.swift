import BSON

extension Unidoc
{
    @frozen public
    enum BuildLogType:String, BSONDecodable, BSONEncodable, Equatable, Sendable
    {
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
        case .ssgc:             "build"
        case .ssgcDiagnostics:  "documentation"
        }
    }
}
