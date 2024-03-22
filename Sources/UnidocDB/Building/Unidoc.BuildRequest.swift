import BSON
import UnidocAPI

extension Unidoc
{
    @frozen public
    enum BuildRequest:Int32, Equatable, Sendable
    {
        case generic = 0
        case release = 1
        case prerelease = 2
    }
}
extension Unidoc.BuildRequest
{
    @inlinable public static
    func force(_ value:Unidoc.BuildLatest?) -> Self
    {
        switch value
        {
        case .prerelease?:  .prerelease
        case .release?:     .release
        case nil:           .generic
        }
    }

    @inlinable public
    var forced:Unidoc.BuildLatest?
    {
        switch self
        {
        case .generic:
            return nil
        case .release:
            return .release
        case .prerelease:
            return .prerelease
        }
    }
}
extension Unidoc.BuildRequest:BSONDecodable, BSONEncodable
{
}
