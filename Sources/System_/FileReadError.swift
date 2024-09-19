public
enum FileReadError:Error, Equatable, Sendable
{
    case incomplete(read:Int, of:Int)
}
extension FileReadError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .incomplete(read: let bytes, of: let expected):
            "Could only read \(bytes) of \(expected) bytes."
        }
    }
}
