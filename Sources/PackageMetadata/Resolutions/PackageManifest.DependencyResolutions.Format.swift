import JSON

extension PackageManifest.DependencyResolutions
{
    @frozen public
    enum Format:UInt, Equatable, Hashable, Sendable
    {
        case v1 = 1
        case v2 = 2
    }
}
extension PackageManifest.DependencyResolutions.Format:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.rawValue < rhs.rawValue
    }
}
extension PackageManifest.DependencyResolutions.Format:JSONDecodable, JSONEncodable
{
}
