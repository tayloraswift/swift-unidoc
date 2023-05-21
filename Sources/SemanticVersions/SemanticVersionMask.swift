@frozen public
enum SemanticVersionMask:Equatable, Hashable, Sendable
{
    case major(UInt16)
    case minor(UInt16, UInt16)
    case patch(UInt16, UInt16, UInt16)

    @inlinable public
    init(_ full:SemanticVersion)
    {
        self = .patch(full.major, full.minor, full.patch)
    }
}
extension SemanticVersionMask
{
    @inlinable public
    init(_ major:UInt16, _ minor:UInt16?, _ patch:@autoclosure () throws -> UInt16?) rethrows
    {
        if  let minor:UInt16
        {
            if let patch:UInt16 = try patch()
            {
                self = .patch(major, minor, patch)
            }
            else
            {
                self = .minor(major, minor)
            }
        }
        else
        {
            self = .major(major)
        }
    }
}
extension SemanticVersionMask:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .major(let major):
            return "\(major)"
        case .minor(let major, let minor):
            return "\(major).\(minor)"
        case .patch(let major, let minor, let patch):
            return "\(major).\(minor).\(patch)"
        }
    }
}
extension SemanticVersionMask:LosslessStringConvertible
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

        guard components.count > 0, let major:UInt16 = .init(components[0])
        else
        {
            return nil
        }
        guard components.count > 1
        else
        {
            self = .major(major)
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
            self = .minor(major, minor)
            return
        }
        guard components.count == 3, let patch:UInt16 = .init(components[2])
        else
        {
            return nil
        }
        self = .patch(major, minor, patch)
    }
}
