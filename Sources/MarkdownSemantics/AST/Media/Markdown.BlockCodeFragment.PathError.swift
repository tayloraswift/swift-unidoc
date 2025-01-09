extension Markdown.BlockCodeFragment
{
    enum PathError:Error
    {
        case directory(String)
        case format(String)
    }
}
