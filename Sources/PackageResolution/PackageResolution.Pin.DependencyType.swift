import JSONDecoding
import JSONEncoding

extension PackageResolution.Pin
{
    @frozen public
    enum DependencyType:String, Hashable, Equatable, Sendable
    {
        case remoteSourceControl
        case localSourceControl
    }
}
extension PackageResolution.Pin.DependencyType:JSONDecodable, JSONEncodable
{
}
