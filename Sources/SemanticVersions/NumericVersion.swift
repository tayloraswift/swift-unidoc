@frozen public
enum NumericVersion:Equatable, Hashable, Comparable, Sendable
{
    case major(MajorVersion)
    case minor(MinorVersion)
    case patch(PatchVersion)
}
extension NumericVersion
{
    @inlinable public
    init(_ major:Int16, _ minor:UInt16?, _ patch:@autoclosure () throws -> UInt16?) rethrows
    {
        if  let minor:UInt16
        {
            if let patch:UInt16 = try patch()
            {
                self = .patch(.v(major, minor, patch))
            }
            else
            {
                self = .minor(.v(major, minor))
            }
        }
        else
        {
            self = .major(.v(major))
        }
    }
}
extension NumericVersion:RawRepresentable
{
    @inlinable public
    var rawValue:Int64
    {
        switch self
        {
        case .major(let version):   Precision.major.rawValue | version.rawValue
        case .minor(let version):   Precision.minor.rawValue | version.rawValue
        case .patch(let version):   Precision.patch.rawValue | version.rawValue
        }
    }
    @inlinable public
    init?(rawValue:Int64)
    {
        switch Precision.init(rawValue: rawValue & 0xff)
        {
        case nil:       return nil
        case .major?:   self = .major(.init(rawValue: rawValue))
        case .minor?:   self = .minor(.init(rawValue: rawValue))
        case .patch?:   self = .patch(.init(rawValue: rawValue))
        }
    }
}
extension NumericVersion:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .major(let version):   "\(version)"
        case .minor(let version):   "\(version)"
        case .patch(let version):   "\(version)"
        }
    }
}
extension NumericVersion:LosslessStringConvertible
{
    @inlinable public
    init?<String>(_ string:String) where String:StringProtocol
    {
        let components:[String.SubSequence] = string.split(separator: ".", maxSplits: 2,
            omittingEmptySubsequences: false)

        guard components.count > 0, let major:Int16 = .init(components[0])
        else
        {
            return nil
        }
        guard components.count > 1
        else
        {
            self = .major(.v(major))
            return
        }
        guard let minor:UInt16 = .init(components[1])
        else
        {
            return nil
        }
        guard components.count > 2
        else
        {
            self = .minor(.v(major, minor))
            return
        }
        guard components.count == 3, let patch:UInt16 = .init(components[2])
        else
        {
            return nil
        }
        self = .patch(.v(major, minor, patch))
    }
}
