import HTTP

extension HTTP
{
    @frozen public
    enum ActivityTimeoutError:Error
    {
        case connection
        case stream
    }
}
extension HTTP.ActivityTimeoutError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .connection:   "Connection timed out before peer initiated any streams"
        case .stream:       "Stream timed out before peer sent any headers"
        }
    }
}
