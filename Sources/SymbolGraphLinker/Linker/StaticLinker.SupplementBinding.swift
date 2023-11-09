import ModuleGraphs

extension StaticLinker
{
    enum SupplementBinding
    {
        case none(in:ModuleIdentifier)
        case vector(Int32, self:Int32)
    }
}
