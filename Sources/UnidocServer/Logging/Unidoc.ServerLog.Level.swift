extension Unidoc.ServerLog
{
    @frozen public
    enum Level:Comparable, Equatable
    {
        case debug
        case error
    }
}
extension Unidoc.ServerLog.Level:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .debug:    "debug"
        case .error:    "error"
        }
    }
}
