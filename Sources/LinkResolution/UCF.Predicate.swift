import FNV1
import Symbols
import UCF

extension UCF
{
    struct Predicate
    {
        let checkedBool:[(Condition, Bool)]
        //  If we add more types, add them here...

        let signature:SignatureFilter?
        let legacy:LegacyFilter?
        let hash:FNV24?
        let seal:Selector.Seal?

        private
        init(checkedBool:[(Condition, Bool)],
            signature:SignatureFilter?,
            legacy:LegacyFilter?,
            hash:FNV24?,
            seal:Selector.Seal?)
        {
            self.checkedBool = checkedBool
            self.signature = signature
            self.legacy = legacy
            self.hash = hash
            self.seal = seal
        }
    }
}
extension UCF.Predicate
{
    init(from selector:UCF.Selector) throws
    {
        let conditions:[UCF.ConditionFilter]
        let signature:UCF.SignatureFilter?
        let legacy:UCF.LegacyFilter?
        let hash:FNV24?

        switch selector.suffix
        {
        case .unidoc(let disambiguator)?:
            conditions = disambiguator.conditions
            signature = disambiguator.signature
            legacy = nil
            hash = nil

        case .legacy(let filter, let fnv1)?:
            conditions = []
            signature = nil
            legacy = filter
            hash = fnv1

        case .hash(let fnv1)?:
            conditions = []
            signature = nil
            legacy = nil
            hash = fnv1

        case nil:
            conditions = []
            signature = nil
            legacy = nil
            hash = nil
        }

        let checked:
        (
            bool:[(UCF.Condition, Bool)],
            _:Void
        ) = try conditions.reduce(into: ([], ()))
        {
            switch $1.label
            {
            case .actor:            $0.bool.append(try $1(default: true))
            case .associatedtype:   $0.bool.append(try $1(default: true))
            case .enum:             $0.bool.append(try $1(default: true))
            case .case:             $0.bool.append(try $1(default: true))
            case .class:            $0.bool.append(try $1(default: true))
            case .class_func:       $0.bool.append(try $1(default: true))
            case .class_subscript:  $0.bool.append(try $1(default: true))
            case .class_var:        $0.bool.append(try $1(default: true))
            case .deinit:           $0.bool.append(try $1(default: true))
            case .func:             $0.bool.append(try $1(default: true))
            case .`init`:           $0.bool.append(try $1(default: true))
            case .macro:            $0.bool.append(try $1(default: true))
            case .protocol:         $0.bool.append(try $1(default: true))
            case .static_func:      $0.bool.append(try $1(default: true))
            case .static_subscript: $0.bool.append(try $1(default: true))
            case .static_var:       $0.bool.append(try $1(default: true))
            case .struct:           $0.bool.append(try $1(default: true))
            case .subscript:        $0.bool.append(try $1(default: true))
            case .typealias:        $0.bool.append(try $1(default: true))
            case .var:              $0.bool.append(try $1(default: true))
            case .async:            $0.bool.append(try $1(default: true))
            case .requirement:      $0.bool.append(try $1(default: true))
            default:                return
            }
        }

        self.init(checkedBool: checked.bool,
            signature: signature,
            legacy: legacy,
            hash: hash,
            seal: selector.path.seal)
    }
}
extension UCF.Predicate
{
    static func ~= (self:Self, traits:UCF.DisambiguationTraits) -> Bool
    {
        if  case nil = self.seal
        {
            //  Macros are currently the only kind of declaration that *must* be spelled with
            //  trailing parentheses.
            switch traits.phylum
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
            switch traits.phylum
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

        if  let signature:UCF.SignatureFilter = self.signature
        {
            //  If a signature filter is present, the declaration must have an autograph.
            guard
            let autograph:UCF.Autograph = traits.autograph, signature ~= autograph
            else
            {
                return false
            }
        }
        if  let filter:UCF.LegacyFilter = self.legacy
        {
            guard filter ~= traits.phylum
            else
            {
                return false
            }
        }
        if  let hash:FNV24 = self.hash
        {
            guard hash == traits.hash
            else
            {
                return false
            }
        }

        let kinks:Phylum.Decl.Kinks = traits.kinks
        let decl:Phylum.Decl = traits.phylum

        for (condition, expected):(UCF.Condition, Bool) in self.checkedBool
        {
            let given:Bool

            switch (decl, condition)
            {
            case (.actor,                   .actor):            given = true
            case (.associatedtype,          .associatedtype):   given = true
            case (.case,                    .case):             given = true
            case (.class,                   .class):            given = true
            case (.deinitializer,           .deinit):           given = true
            case (.enum,                    .enum):             given = true
            case (.func(nil),               .func):             given = true
            case (.func(.instance),         .func):             given = true
            case (.func(.class?),           .class_func):       given = true
            case (.func(.static?),          .static_func):      given = true
            case (.initializer,             .`init`):           given = true
            case (.macro,                   .macro):            given = true
            case (.protocol,                .protocol):         given = true
            case (.struct,                  .struct):           given = true
            case (.subscript(.instance),    .subscript):        given = true
            case (.subscript(.class),       .class_subscript):  given = true
            case (.subscript(.static),      .static_subscript): given = true
            case (.typealias,               .typealias):        given = true
            case (.var(nil),                .var):              given = true
            case (.var(.instance?),         .var):              given = true
            case (.var(.class?),            .class_var):        given = true
            case (.var(.static?),           .static_var):       given = true

            case (_,                        .actor):            given = false
            case (_,                        .associatedtype):   given = false
            case (_,                        .case):             given = false
            case (_,                        .class):            given = false
            case (_,                        .deinit):           given = false
            case (_,                        .enum):             given = false
            case (_,                        .func):             given = false
            case (_,                        .class_func):       given = false
            case (_,                        .static_func):      given = false
            case (_,                        .`init`):           given = false
            case (_,                        .macro):            given = false
            case (_,                        .protocol):         given = false
            case (_,                        .struct):           given = false
            case (_,                        .subscript):        given = false
            case (_,                        .class_subscript):  given = false
            case (_,                        .static_subscript): given = false
            case (_,                        .typealias):        given = false
            case (_,                        .var):              given = false
            case (_,                        .class_var):        given = false
            case (_,                        .static_var):       given = false

            case (_,                        .async):            given = traits.async
            case (_,                        .requirement):      given = kinks[is: .required]
            default:                                            continue
            }

            if  given != expected
            {
                return false
            }
        }

        return true
    }
}
