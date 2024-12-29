extension UCF
{
    enum TypeSigil
    {
        case tilde
    }
}
extension UCF.TypeSigil
{
    var text:String
    {
        switch self
        {
        case .tilde:    "~"
        }
    }
}
