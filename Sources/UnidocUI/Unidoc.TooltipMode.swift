extension Unidoc
{
    enum TooltipMode
    {
        case omit
        case declaration
    }
}
extension Unidoc.TooltipMode
{
    var code:String
    {
        switch self
        {
        case .omit:         "n"
        case .declaration:  "d"
        }
    }
}
