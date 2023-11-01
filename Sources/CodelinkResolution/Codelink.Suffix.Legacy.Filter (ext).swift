import Codelinks
import Unidoc

extension Codelink.Suffix.Legacy.Filter
{
    static
    func ~= (self:Self, phylum:Unidoc.Decl?) -> Bool
    {
        guard
        let phylum:Unidoc.Decl
        else
        {
            return false
        }

        switch  (phylum, self)
        {
        case    (.actor,                .class),
                (.associatedtype,       .associatedtype),
                (.case,                 .enum_case),
                (.class,                .class),
                (.deinitializer,        .deinit),
                (.enum,                 .enum),
                (.func(nil),            .func),
                (.func(nil),            .func_op),
                (.func(.instance),      .method),
                (.func(.class?),        .type_method),
                (.func(.static?),       .type_method),
                (.func(.static?),       .func_op),
                (.initializer,          .`init`),
                (.macro,                .macro),
                (.protocol,             .protocol),
                (.struct,               .struct),
                (.subscript(.instance), .subscript),
                (.subscript(.class),    .type_subscript),
                (.subscript(.static),   .type_subscript),
                (.typealias,            .typealias),
                (.var(nil),             .var),
                (.var(.instance?),      .property),
                (.var(.class?),         .type_property),
                (.var(.static?),        .type_property):
            return true

        default:
            return false
        }
    }
}
