import Symbols
import UCF

extension SSGC.SupplementBindingError
{
    enum Variant:Sendable
    {
        case ambiguousBinding([any UCF.ResolvableOverload],
            rejected:[any UCF.ResolvableOverload])

        case moduleNotAllowed(Symbol.Module, expected:Symbol.Module)
        case vectorNotAllowed(Int32, self:Int32)
    }
}
