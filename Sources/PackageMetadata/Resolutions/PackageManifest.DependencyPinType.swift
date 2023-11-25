import JSON

extension PackageManifest
{
    enum DependencyPinType:String, Hashable, Equatable, Sendable
    {
        case remoteSourceControl
        case localSourceControl
    }
}
extension PackageManifest.DependencyPinType:JSONDecodable, JSONEncodable
{
}
