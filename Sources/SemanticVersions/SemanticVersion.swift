@frozen public 
struct SemanticVersion:Sendable 
{
    public 
    var major:UInt16 
    public 
    var minor:UInt16 
    public 
    var patch:UInt16 

    @inlinable public 
    init(_ major:UInt16, _ minor:UInt16, _ patch:UInt16)
    {
        self.major = major 
        self.minor = minor 
        self.patch = patch 
    }
}
extension SemanticVersion:Hashable, Comparable 
{
    @inlinable public static 
    func < (lhs:Self, rhs:Self) -> Bool 
    {
        (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch)
    }
}
extension SemanticVersion:CustomStringConvertible
{
    @inlinable public 
    var description:String
    {
        "\(self.major).\(self.minor).\(self.patch)"
    }
}
