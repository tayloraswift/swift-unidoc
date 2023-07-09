extension PatchVersion
{
    @frozen public
    struct Components:Equatable, Hashable, Sendable
    {
        public
        var major:UInt16
        public
        var minor:UInt16
        public
        var patch:UInt16

        @inlinable internal
        init(major:UInt16, minor:UInt16, patch:UInt16)
        {
            self.major = major
            self.minor = minor
            self.patch = patch
        }
    }
}
extension PatchVersion.Components:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch)
    }
}
extension PatchVersion.Components:RawRepresentable
{
    @inlinable public
    var rawValue:Int64
    {
        Int64.init(self.major) << 48 |
        Int64.init(self.minor) << 32 |
        Int64.init(self.patch) << 16
    }
    @inlinable public
    init(rawValue:Int64)
    {
        let major:UInt16 = .init(truncatingIfNeeded: rawValue >> 48)
        let minor:UInt16 = .init(truncatingIfNeeded: rawValue >> 32)
        let patch:UInt16 = .init(truncatingIfNeeded: rawValue >> 16)
        self.init(major: major, minor: minor, patch: patch)
    }
}
extension PatchVersion.Components:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "\(self.major).\(self.minor).\(self.patch)"
    }
}
extension PatchVersion.Components:LosslessStringConvertible, VectorVersionComponents
{
    @inlinable public
    init?(_ string:String)
    {
        self.init(string[...])
    }
    @inlinable public
    init?(_ string:Substring)
    {
        let components:[Substring] = string.split(separator: ".", maxSplits: 2,
            omittingEmptySubsequences: false)
        if  components.count == 3
        {
            self.init((components[0], components[1], components[2]))
        }
        else
        {
            return nil
        }
    }
    @inlinable internal
    init?(_ components:(Substring, Substring, Substring))
    {
        if  let major:UInt16 = .init(components.0),
            let minor:UInt16 = .init(components.1),
            let patch:UInt16 = .init(components.2)
        {
            self.init(major: major, minor: minor, patch: patch)
        }
        else
        {
            return nil
        }
    }
}
