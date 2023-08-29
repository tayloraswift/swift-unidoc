
import Sources
import Unidoc

extension DynamicContext.SortPriority
{
    enum Phylum:Equatable, Comparable
    {
        case `var`
        case `func`

        case `associatedtype`

        /// Enumeration cases sort by their declaration order. Because it is impossible for
        /// them to appear in a different file than the enum’s declaration, we can simply use
        /// the source position of the case declaration.
        case `case`(SourcePosition)
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
extension DynamicContext.SortPriority.Phylum
{
    init(_ phylum:Unidoc.Decl, position:SourcePosition? = nil)
    {
        switch phylum
        {
        case    .var(nil):                      self = .var
        case    .func(nil):                     self = .func
        case    .associatedtype:                self = .associatedtype
        case    .case:                          self = .case(position ?? .zero)
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
