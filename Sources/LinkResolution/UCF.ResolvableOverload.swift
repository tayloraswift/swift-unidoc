import FNV1
import Symbols
import UCF

extension UCF
{
    public
    protocol ResolvableOverload:Identifiable<Symbol.Decl>, Sendable
    {
        var phylum:Phylum.Decl { get }
        var hash:FNV24 { get }

        var documented:Bool { get }
    }
}
extension UCF.ResolvableOverload
{
    static func ~= (predicate:UCF.Predicate, self:Self) -> Bool
    {
        if  predicate.hasEmptyTrailingParentheses
        {
            switch self.phylum
            {
            case .actor:                    return false
            case .associatedtype:           return false
            case .case:                     return false
            case .class:                    return false
            case .deinitializer:            return false
            case .enum:                     return false
            case .func:                     break
            case .initializer:              break
            case .macro:                    break
            case .operator:                 break
            case .protocol:                 return false
            case .struct:                   return false
            case .subscript:                break
            case .typealias:                return false
            case .var:                      return false
            }
        }

        guard 
        let suffix:UCF.Selector.Suffix = predicate.suffix
        else
        {
            return true
        }

        switch suffix
        {
        case .legacy(let filter, nil):      return filter ~= self.phylum
        case .legacy(_, let hash?):         return hash == self.hash
        case .hash(let hash):               return hash == self.hash
        case .filter(let filter):           return filter ~= self.phylum
        }
    }
}
