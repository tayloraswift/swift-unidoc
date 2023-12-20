extension UA
{
    @frozen public
    enum Version:Equatable, Hashable, Sendable
    {
        case numeric(Int, String?)
        case nominal(String)
    }
}
extension UA.Version
{
    @inlinable public
    var major:Int?
    {
        switch self
        {
        case .numeric(let major, _):    major
        case .nominal:                  nil
        }
    }
}
extension UA.Version:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .numeric(let major, let suffix?):  "\(major).\(suffix)"
        case .numeric(let major, nil):          "\(major)"
        case .nominal(let name):                name
        }
    }
}
