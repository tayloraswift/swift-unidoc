extension Symbol
{
    @frozen public
    enum FileBaseError:Equatable, Error
    {
        case rebasing(uri:String, against:FileBase)
    }
}
extension Symbol.FileBaseError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .rebasing(uri: let uri, against: let base):
            "Cannot rebase '\(uri)' against '\(base)'."
        }
    }
}
