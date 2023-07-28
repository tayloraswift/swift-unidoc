import ModuleGraphs

extension SupplementBindingError
{
    enum Resolution
    {
        case none(in:ModuleIdentifier)
        case vector(Int32, self:Int32)
    }
}
