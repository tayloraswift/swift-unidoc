import UnidocRecords

extension Volume
{
    enum StemComponentError:Error, Equatable, Sendable
    {
        case empty
    }
}
extension Volume.StemComponentError:CustomStringConvertible
{
    var description:String
    {
        "stem cannot be empty"
    }
}
