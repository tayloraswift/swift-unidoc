import SymbolColonies

extension Compiler
{
    @frozen public 
    enum ScalarPhylum:Hashable, Sendable
    {
        case  actor
        case `associatedtype`
        case `case`
        case `class`
        case  deinitializer
        case `enum`
        case `func`(SymbolObjectivity?)
        case  initializer
        case `operator`
        case `protocol`
        case `struct`
        case `subscript`(SymbolObjectivity)
        case `typealias`
        case `var`(SymbolObjectivity?)
    }
}
extension Compiler.ScalarPhylum
{
    init?(_ phylum:SymbolDescription.Phylum)
    {
        switch phylum
        {
        case .actor:                        self = .actor
        case .associatedtype:               self = .associatedtype
        case .case:                         self = .case
        case .class:                        self = .class
        case .deinitializer:                self = .deinitializer
        case .enum:                         self = .enum
        case .func(let objectivity):        self = .func(objectivity)
        case .initializer:                  self = .initializer
        case .protocol:                     self = .protocol
        case .subscript(let objectivity):   self = .subscript(objectivity)
        case .operator:                     self = .operator
        case .struct:                       self = .struct
        case .typealias:                    self = .typealias
        case .var(let objectivity):         self = .var(objectivity)
        case .extension, .macro:            return nil
        }
    }
}
