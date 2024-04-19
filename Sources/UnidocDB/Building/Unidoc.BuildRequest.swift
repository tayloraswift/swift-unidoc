import BSON
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct BuildRequest:Equatable, Sendable
    {
        public
        let series:VersionSeries
        public
        let force:Bool

        @inlinable public
        init(series:VersionSeries, force:Bool)
        {
            self.series = series
            self.force = force
        }
    }
}
extension Unidoc.BuildRequest:RawRepresentable
{
    @inlinable public
    init?(rawValue:Int32)
    {
        switch rawValue
        {
        case 0:     self = .init(series: .release, force: false)
        case 1:     self = .init(series: .release, force: true)
        case 2:     self = .init(series: .prerelease, force: false)
        case 3:     self = .init(series: .prerelease, force: true)
        default:    return nil
        }
    }

    @inlinable public
    var rawValue:Int32
    {
        switch (self.series, self.force)
        {
        case (.release, false):     0
        case (.release, true):      1
        case (.prerelease, false):  2
        case (.prerelease, true):   3
        }
    }
}
extension Unidoc.BuildRequest:BSONDecodable, BSONEncodable
{
}
