extension MediaType
{
    @frozen public
    enum Charset:String, Equatable, Hashable, Sendable
    {
        case utf8 = "utf-8"
    }
}
extension MediaType.Charset:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
extension MediaType.Charset:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        self.init(rawValue: description)
    }
}
