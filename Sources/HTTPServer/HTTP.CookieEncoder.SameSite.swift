extension HTTP.CookieEncoder
{
    @frozen public
    enum SameSite:String
    {
        case strict = "Strict"
        case lax    = "Lax"
        case none   = "None"
    }
}
extension HTTP.CookieEncoder.SameSite:CustomStringConvertible
{
    @inlinable public
    var description:String { self.rawValue }
}
