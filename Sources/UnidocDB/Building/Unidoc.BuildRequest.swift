import BSON
import UnidocAPI

extension Unidoc
{
    @frozen public
    enum BuildRequest:Int32, Equatable, Sendable
    {
        case auto = 0
        case release = 1
        case prerelease = 2
    }
}
extension Unidoc.BuildRequest
{
    @inlinable public static
    func force(_ value:Unidoc.VersionSeries) -> Self
    {
        switch value
        {
        case .prerelease:   .prerelease
        case .release:      .release
        }
    }

    @inlinable public
    var forced:Unidoc.VersionSeries?
    {
        switch self
        {
        case .auto:         nil
        case .release:      .release
        case .prerelease:   .prerelease
        }
    }

    @inlinable public
    var series:Unidoc.VersionSeries
    {
        switch self
        {
        case .auto:         .release
        case .release:      .release
        case .prerelease:   .prerelease
        }
    }
}
extension Unidoc.BuildRequest:BSONDecodable, BSONEncodable
{
}
