@frozen public
enum MediaEncoding:String, Equatable, Hashable, Sendable
{
    case utf8 = "utf-8"
}
extension MediaEncoding:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
