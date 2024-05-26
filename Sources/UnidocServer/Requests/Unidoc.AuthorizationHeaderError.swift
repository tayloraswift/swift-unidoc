extension Unidoc
{
    @frozen public
    enum AuthorizationHeaderError:Error
    {
        case scheme(Substring)
        case format(Substring)
    }
}
extension Unidoc.AuthorizationHeaderError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .scheme(let scheme):
            "Invalid authorization scheme '\(scheme)', expected 'Unidoc'"
        case .format(let format):
            "Invalid authorization format '\(format)' for header scheme 'Unidoc'"
        }
    }
}
