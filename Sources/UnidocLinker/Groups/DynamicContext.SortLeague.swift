import Unidoc

extension DynamicContext
{
    enum SortLeague:Equatable, Comparable
    {
        case `var`
        case `func`

        case `associatedtype`

        case `case`
        case  initializer
        case  deinitializer

        case `protocol`
        case  type
        case `typealias`

        case `subscript`(Unidoc.Decl.Objectivity)
        case `operator`
        case  property(Unidoc.Decl.Objectivity)
        case  method(Unidoc.Decl.Objectivity)
    }
}
extension DynamicContext.SortLeague
{
    init(_ phylum:Unidoc.Decl)
    {
        switch phylum
        {
        case    .var(nil):                      self = .var
        case    .func(nil):                     self = .func
        case    .associatedtype:                self = .associatedtype
        case    .case:                          self = .case
        case    .initializer:                   self = .initializer
        case    .deinitializer:                 self = .deinitializer
        case    .protocol:                      self = .protocol

        case    .actor,
                .class,
                .enum,
                .struct:                        self = .type

        case    .typealias:                     self = .typealias
        case    .subscript(let objectivity):    self = .subscript(objectivity)
        case    .operator:                      self = .operator
        case    .var(let objectivity?):         self = .property(objectivity)
        case    .func(let objectivity?):        self = .method(objectivity)
        }
    }
}
