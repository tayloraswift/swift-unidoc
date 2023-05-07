import JSONDecoding
import JSONEncoding

extension PackageResolutions
{
    public
    enum FormatVersion:UInt, Equatable, Hashable, Sendable
    {
        case v1 = 1
        case v2 = 2
    }
}
extension PackageResolutions.FormatVersion:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.rawValue < rhs.rawValue
    }
}
extension PackageResolutions.FormatVersion:JSONDecodable, JSONEncodable
{
}
