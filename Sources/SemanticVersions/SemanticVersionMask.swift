@frozen public 
enum SemanticVersionMask:Hashable, Sendable
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
