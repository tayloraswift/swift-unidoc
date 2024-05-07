import BSON
import UnidocAPI

extension Unidoc.VersionSeries:RawRepresentable
{
    @inlinable public
    var rawValue:Bool
    {
        //  DO NOT simplify this to `self == .release`! It will cause a stack overflow.
        switch self
        {
        case .prerelease:   false
        case .release:      true
        }
    }

    @inlinable public
    init?(rawValue:Bool)
    {
        self = rawValue ? .release : .prerelease
    }
}
extension Unidoc.VersionSeries:BSONDecodable, BSONEncodable
{
}
