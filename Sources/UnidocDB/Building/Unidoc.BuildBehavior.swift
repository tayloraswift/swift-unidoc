import BSON
import UnidocAPI

extension Unidoc
{
    @frozen public
    enum BuildBehavior:Equatable, Sendable
    {
        case latest(VersionSeries, force:Bool)
        case id(force:Bool)
    }
}
extension Unidoc.BuildBehavior:RawRepresentable
{
    @inlinable public
    init?(rawValue:Int32)
    {
        switch rawValue
        {
        case 0:     self = .latest(.release, force: false)
        case 1:     self = .latest(.release, force: true)
        case 2:     self = .latest(.prerelease, force: false)
        case 3:     self = .latest(.prerelease, force: true)
        case 256:   self = .id(force: false)
        case 257:   self = .id(force: true)
        default:    return nil
        }
    }

    @inlinable public
    var rawValue:Int32
    {
        switch self
        {
        case .latest(.release, false):      0
        case .latest(.release, true):       1
        case .latest(.prerelease, false):   2
        case .latest(.prerelease, true):    3
        case .id(false):                    256
        case .id(true):                     257
        }
    }
}
extension Unidoc.BuildBehavior:BSONDecodable, BSONEncodable
{
}
