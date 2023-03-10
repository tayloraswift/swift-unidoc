extension SemanticVersion 
{
    @frozen public 
    enum Masked:Hashable, Sendable
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
}
extension SemanticVersion.Masked:CustomStringConvertible 
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