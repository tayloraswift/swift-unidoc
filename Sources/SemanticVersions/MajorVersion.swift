@frozen public
struct MajorVersion:Equatable, Hashable, Sendable
{
    public
    var number:Int16

    @inlinable internal
    init(number:Int16)
    {
        self.number = number
    }
}
extension MajorVersion
{
    @inlinable public static
    func v(_ number:Int16) -> Self
    {
        self.init(number: number)
    }
}
extension MajorVersion:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.number < rhs.number
    }
}
extension MajorVersion:RawRepresentable
{
    @inlinable public
    var rawValue:Int64
    {
        Int64.init(self.number) << 48
    }
    @inlinable public
    init(rawValue:Int64)
    {
        let major:Int16 = .init(truncatingIfNeeded: rawValue >> 48)
        self = .v(major)
    }
}
extension MajorVersion:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.number)" }
}
extension MajorVersion:LosslessStringConvertible
{
    @inlinable public
    init?(_ string:String)
    {
        self.init(string[...])
    }
    @inlinable public
    init?(_ string:Substring)
    {
        if  let number:Int16 = .init(string)
        {
            self.init(number: number)
        }
        else
        {
            return nil
        }
    }
}
