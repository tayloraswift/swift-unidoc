import UnidocRecords

extension Volume
{
    enum LookupOutputError:Error, Equatable, Sendable
    {
        case malformed
    }
}
extension Volume.LookupOutputError:CustomStringConvertible
{
    var description:String
    {
        "malformed query output"
    }
}
