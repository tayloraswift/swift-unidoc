extension StaticLinker.BindingError
{
    @frozen public
    enum Resolution:Sendable
    {
        case ambiguous([StaticLinker.Excerpt])
        case vector(StaticLinker.Excerpt)
    }
}
