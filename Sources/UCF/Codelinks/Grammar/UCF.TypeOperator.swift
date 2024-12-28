extension UCF
{
    enum TypeOperator
    {
        case exclamation
        case question
        case metatype
    }
}
extension UCF.TypeOperator
{
    var text:String
    {
        switch self
        {
        case .exclamation:  "!"
        case .question:     "?"
        case .metatype:     ".Type"
        }
    }
}
