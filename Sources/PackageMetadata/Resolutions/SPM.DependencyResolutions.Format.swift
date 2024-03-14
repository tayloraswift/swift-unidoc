import JSON

extension SPM.DependencyResolutions
{
    @frozen public
    enum Format:UInt, Equatable, Hashable, Sendable
    {
        case v1 = 1
        case v2 = 2
        case v3 = 3
    }
}
extension SPM.DependencyResolutions.Format:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.rawValue < rhs.rawValue
    }
}
extension SPM.DependencyResolutions.Format:JSONDecodable, JSONEncodable
{
}
