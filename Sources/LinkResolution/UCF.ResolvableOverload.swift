import FNV1
import Symbols
import UCF

extension UCF
{
    public
    protocol ResolvableOverload:Identifiable<Symbol.Decl>, Sendable
    {
        var autograph:Autograph? { get }
        var phylum:Phylum.Decl { get }
        var kinks:Phylum.Decl.Kinks { get }
        var hash:FNV24 { get }

        var documented:Bool { get }
    }
}
extension UCF.ResolvableOverload
{
    static func ~= (predicate:UCF.Predicate, self:Self) -> Bool
    {
        if  case nil = predicate.seal
        {
            //  Macros are currently the only kind of declaration that *must* be spelled with
            //  trailing parentheses.
            switch self.phylum
            {
            case .actor:                    break
            case .associatedtype:           break
            case .case:                     break
            case .class:                    break
            case .deinitializer:            break
            case .enum:                     break
            case .func:                     break
            case .initializer:              break
            case .macro:                    return false
            case .operator:                 break
            case .protocol:                 break
            case .struct:                   break
            case .subscript:                break
            case .typealias:                break
            case .var:                      break
            }
        }
        else
        {
            switch self.phylum
            {
            case .actor:                    return false
            case .associatedtype:           return false
            case .case:                     break
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
        case .unidoc(let filter):
            if  let signature:UCF.SignatureFilter = filter.signature
            {
                //  If a signature filter is present, the declaration must have an autograph.
                guard
                let autograph:UCF.Autograph = self.autograph, signature ~= autograph
                else
                {
                    return false
                }
            }

            let decl:(Phylum.Decl, Phylum.Decl.Kinks) = (self.phylum, self.kinks)
            for condition:UCF.ConditionFilter in filter.conditions
            {
                guard condition ~= decl
                else
                {
                    return false
                }
            }

            return true

        case .legacy(let filter, nil):
            return filter ~= self.phylum

        case .legacy(_, let hash?):
            return hash == self.hash

        case .hash(let hash):
            return hash == self.hash
        }
    }
}
