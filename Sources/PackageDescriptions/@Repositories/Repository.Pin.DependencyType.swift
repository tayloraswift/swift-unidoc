import JSONDecoding
import JSONEncoding

extension Repository.Pin
{
    enum DependencyType:String, Hashable, Equatable, Sendable
    {
        case remoteSourceControl
        case localSourceControl
    }
}
extension Repository.Pin.DependencyType:JSONDecodable, JSONEncodable
{
}
