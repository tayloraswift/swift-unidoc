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
extension UCF.Resolution where Overload:UCF.ResolvableOverload
{
    static func choose(among overloads:[Symbol.Decl: Overload], 
        rejected:[Symbol.Decl: Overload]) -> Self
    {
        var documentedOverload:Overload? 
        var documentedCount:Int = 0

        for candidate:Overload in overloads.values
        {
            if  candidate.documented
            {
                documentedOverload = candidate
                documentedCount += 1
            }
        }

        if  let documentedOverload:Overload, documentedCount == 1
        {
            return .overload(documentedOverload)
        }
        else 
        {
            return .ambiguous(overloads.values.sorted { $0.id < $1.id }, 
                    rejected: rejected.values.sorted { $0.id < $1.id })
        }
    }
}
