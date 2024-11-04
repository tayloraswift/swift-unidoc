extension HTTP
{
    @frozen public
    enum LogLevel:Comparable, Equatable
    {
        case debug
        case error
    }
}
