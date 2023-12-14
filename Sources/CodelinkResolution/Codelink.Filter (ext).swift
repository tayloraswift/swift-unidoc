import Codelinks
import Symbols

extension Codelink.Filter
{
    static
    func ~= (self:Self, phylum:Phylum.Decl?) -> Bool
    {
        guard
        let phylum:Phylum.Decl
        else
        {
            return false
        }

        switch  (phylum, self)
        {
        case    (.actor,                .actor),
                (.associatedtype,       .associatedtype),
                (.case,                 .case),
                (.class,                .class),
                (.deinitializer,        .deinit),
                (.enum,                 .enum),
                (.func(nil),            .func),
                (.func(.instance),      .func),
                (.func(.class?),        .class_func),
                (.func(.static?),       .static_func),
                (.initializer,          .`init`),
                (.macro,                .macro),
                (.protocol,             .protocol),
                (.struct,               .struct),
                (.subscript(.instance), .subscript),
                (.subscript(.class),    .class_subscript),
                (.subscript(.static),   .static_subscript),
                (.typealias,            .typealias),
                (.var(nil),             .var),
                (.var(.instance?),      .var),
                (.var(.class?),         .class_var),
                (.var(.static?),        .static_var):
            return true

        default:
            return false
        }
    }
}
