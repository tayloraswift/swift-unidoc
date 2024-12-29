import Symbols
import UCF

extension UCF.ConditionFilter
{
    static func ~= (self:Self, decl:(phylum:Phylum.Decl, kinks:Phylum.Decl.Kinks)) -> Bool
    {
        let value:Bool

        switch (decl.phylum, self.keywords)
        {
        case (.actor,                   .actor):            value = true
        case (.associatedtype,          .associatedtype):   value = true
        case (.case,                    .case):             value = true
        case (.class,                   .class):            value = true
        case (.deinitializer,           .deinit):           value = true
        case (.enum,                    .enum):             value = true
        case (.func(nil),               .func):             value = true
        case (.func(.instance),         .func):             value = true
        case (.func(.class?),           .class_func):       value = true
        case (.func(.static?),          .static_func):      value = true
        case (.initializer,             .`init`):           value = true
        case (.macro,                   .macro):            value = true
        case (.protocol,                .protocol):         value = true
        case (.struct,                  .struct):           value = true
        case (.subscript(.instance),    .subscript):        value = true
        case (.subscript(.class),       .class_subscript):  value = true
        case (.subscript(.static),      .static_subscript): value = true
        case (.typealias,               .typealias):        value = true
        case (.var(nil),                .var):              value = true
        case (.var(.instance?),         .var):              value = true
        case (.var(.class?),            .class_var):        value = true
        case (.var(.static?),           .static_var):       value = true
        case (_,                        .requirement):      value = decl.kinks[is: .required]
        default:                                            value = false
        }

        return self.expected == value
    }
}
