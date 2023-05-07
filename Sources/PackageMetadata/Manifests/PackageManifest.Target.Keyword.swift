import JSONDecoding
import JSONEncoding
import Repositories

extension PackageManifest.Target
{
    enum Keyword:String, Sendable
    {
        case binary
        case executable
        case library = "regular"
        case macro
        case plugin
        case system
        case test
    }
}
extension PackageManifest.Target.Keyword
{
    var type:TargetType
    {
        switch self
        {
        case .binary:       return .binary
        case .executable:   return .executable
        case .library:      return .library
        case .macro:        return .macro
        case .plugin:       return .plugin
        case .system:       return .system
        case .test:         return .test
        }
    }
}
extension PackageManifest.Target.Keyword:JSONDecodable, JSONEncodable
{
}
