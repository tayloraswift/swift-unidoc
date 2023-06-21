import ModuleGraphs

extension InvalidArticleBindingError
{
    enum Resolution
    {
        case none(in:ModuleIdentifier)
        case vector(Int32, self:Int32)
    }
}
