extension ScalarVirtuality:RawRepresentable
{
    @inlinable public
    init?(rawValue:UInt8)
    {
        switch rawValue
        {
        case 1: self = .required
        case 2: self = .optional
        case 3: self = .open
        case _: return nil
        }
    }
    @inlinable public
    var rawValue:UInt8
    {
        switch self
        {
        case .required: return 1
        case .optional: return 2
        case .open:     return 3
        }
    }
}
