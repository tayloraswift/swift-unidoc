import JSONDecoding
import JSONEncoding

extension PackageResolution
{
    @frozen public
    enum DependencyType:String, Hashable, Equatable, Sendable
    {
        case remoteSourceControl
    }
}
extension PackageResolution.DependencyType:JSONDecodable, JSONEncodable
{
}
