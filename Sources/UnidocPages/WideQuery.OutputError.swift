import UnidocQueries

extension WideQuery
{
    enum OutputError:Error, Equatable, Sendable
    {
        case malformed
    }
}
extension WideQuery.OutputError:CustomStringConvertible
{
    var description:String
    {
        "malformed query output"
    }
}
