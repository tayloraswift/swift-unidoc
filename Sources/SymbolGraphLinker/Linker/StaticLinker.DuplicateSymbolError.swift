extension StaticLinker
{
    public
    enum DuplicateSymbolError:Equatable, Error, Sendable
    {
        case article(String)
    }
}
