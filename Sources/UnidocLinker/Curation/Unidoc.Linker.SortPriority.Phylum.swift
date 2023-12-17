
import Sources
import Symbols

extension Unidoc.Linker.SortPriority
{
    enum Phylum:Equatable, Comparable
    {
        case `var`
        case `func`

        case `associatedtype`

        /// Enumeration cases sort by their declaration order. Because it is impossible for
        /// them to appear in a different file than the enum’s declaration, we can simply use
        /// the source position of the case declaration.
        case  constructor(Constructor)
        case `class`(Member)
        case  destructor
        case  instance(Member)

        case `protocol`
        case  type
        case `typealias`

        case  macro
    }
}
extension Unidoc.Linker.SortPriority.Phylum
{
    init(_ phylum:Phylum.Decl, position:SourcePosition? = nil)
    {
        switch phylum
        {
        case    .var(nil):                      self = .var
        case    .func(nil):                     self = .func
        case    .associatedtype:                self = .associatedtype

        case    .case:                          self = .constructor(.case(position ?? .zero))
        case    .initializer:                   self = .constructor(.initializer)
        case    .var(.static):                  self = .constructor(.var)
        case    .subscript(.static):            self = .constructor(.subscript)
        case    .func(.static):                 self = .constructor(.func)

        case    .var(.class):                   self = .class(.var)
        case    .subscript(.class):             self = .class(.subscript)
        case    .func(.class):                  self = .class(.func)
        case    .deinitializer:                 self = .destructor

        case    .var(.instance):                self = .instance(.var)
        case    .subscript(.instance):          self = .instance(.subscript)
        case    .operator:                      self = .instance(.operator)
        case    .func(.instance):               self = .instance(.func)

        case    .protocol:                      self = .protocol
        case    .actor,
                .class,
                .enum,
                .struct:                        self = .type
        case    .typealias:                     self = .typealias

        case    .macro:                         self = .macro
        }
    }
}
