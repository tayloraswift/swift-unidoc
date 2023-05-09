import JSONDecoding
import JSONEncoding
import Repositories

extension Repository.Pin.V2
{
    enum DependencyType:String, Hashable, Equatable, Sendable
    {
        case remoteSourceControl
        case localSourceControl
    }
}
extension Repository.Pin.V2.DependencyType:JSONDecodable, JSONEncodable
{
}
