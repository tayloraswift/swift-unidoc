extension Markdown.BlockCodeReference
{
    enum ArgumentError:Error
    {
        case reset(String)
        case resetContradictsBase

        case duplicated(String)
        case unexpected(String)
    }
}
