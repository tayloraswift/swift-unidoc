import Symbols
import UCF

extension UCF
{
    @frozen public
    enum Resolution<Overload>
    {
        case ambiguous([Overload], rejected:[Overload])
        case overload(Overload)
        case module(Symbol.Module)
    }
}
