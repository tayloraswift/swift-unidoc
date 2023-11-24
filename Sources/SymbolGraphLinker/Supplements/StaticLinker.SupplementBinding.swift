import Symbols

extension StaticLinker
{
    enum SupplementBinding
    {
        case none(in:Symbol.Module)
        case vector(Int32, self:Int32)
    }
}
