extension MinorVersion
{
    @frozen public
    struct Components:Equatable, Hashable, Sendable
    {
        public
        var major:Int16
        public
        var minor:UInt16

        @inlinable internal
        init(major:Int16, minor:UInt16)
        {
            self.major = major
            self.minor = minor
        }
    }
}
extension MinorVersion.Components:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.major, lhs.minor) < (rhs.major, rhs.minor)
    }
}
extension MinorVersion.Components:RawRepresentable
{
    @inlinable public
    var rawValue:Int64
    {
        Int64.init(self.major) << 48 |
        Int64.init(self.minor) << 32
    }
    @inlinable public
    init(rawValue:Int64)
    {
        let major:Int16 = .init(truncatingIfNeeded: rawValue >> 48)
        let minor:UInt16 = .init(truncatingIfNeeded: rawValue >> 32)
        self.init(major: major, minor: minor)
    }
}
extension MinorVersion.Components:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.major).\(self.minor)" }
}
extension MinorVersion.Components:LosslessStringConvertible, VectorVersionComponents
{
    @inlinable public
    init?(_ string:String)
    {
        self.init(string[...])
    }
    @inlinable public
    init?(_ string:Substring)
    {
        let components:[Substring] = string.split(separator: ".", maxSplits: 1,
            omittingEmptySubsequences: false)
        if  components.count == 2
        {
            self.init((components[0], components[1]))
        }
        else
        {
            return nil
        }
    }
    @inlinable internal
    init?(_ components:(Substring, Substring))
    {
        if  let major:Int16 = .init(components.0),
            let minor:UInt16 = .init(components.1)
        {
            self.init(major: major, minor: minor)
        }
        else
        {
            return nil
        }
    }
}
