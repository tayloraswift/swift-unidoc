extension Markdown.BlockCodeFragment
{
    enum ReferenceError:Error
    {
        case snippet(undefined:String?, available:[String])
        case slice(undefined:String, available:[String])
    }
}
