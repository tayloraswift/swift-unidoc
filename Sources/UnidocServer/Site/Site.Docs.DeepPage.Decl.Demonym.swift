import HTML
import Unidoc

extension Site.Docs.DeepPage.Decl
{
    struct Demonym
    {
        let customization:Unidoc.Decl.Customization
        let phylum:Unidoc.Decl
    }
}
extension Site.Docs.DeepPage.Decl.Demonym:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        let adjective:String?
        let noun:String
        switch self.phylum
        {
        case .actor:                noun = "Actor"
        case .associatedtype:       noun = "Associated Type"
        case .case:                 noun = "Enumeration Case"
        case .class:                noun = "Class"
        case .deinitializer:        noun = "Deinitializer"
        case .enum:                 noun = "Enumeration"
        case .func(nil):            noun = "Global Function"
        case .func(.class):         noun = "Class Method"
        case .func(.instance):      noun = "Instance Method"
        case .func(.static):        noun = "Static Method"
        case .initializer:          noun = "Initializer"
        case .operator:             noun = "Operator"
        case .protocol:             noun = "Protocol"
        case .struct:               noun = "Structure"
        case .subscript(.class):    noun = "Class Subscript"
        case .subscript(.instance): noun = "Instance Subscript"
        case .subscript(.static):   noun = "Static Subscript"
        case .typealias:            noun = "Type Alias"
        case .var(nil):             noun = "Global Variable"
        case .var(.class):          noun = "Class Property"
        case .var(.instance):       noun = "Instance Property"
        case .var(.static):         noun = "Static Property"
        }

        switch  (self.customization, self.phylum)
        {
        case    (.available,          .class),
                (.available,          .func),
                (.available,          .initializer),
                (.available,          .subscript),
                (.available,          .var):        adjective = "Open"
        case    (.required,           .func),
                (.required,           .initializer),
                (.required,           .subscript),
                (.required,           .var):        adjective = "Required"
        case    (.requiredOptionally, .func),
                (.requiredOptionally, .initializer),
                (.requiredOptionally, .subscript),
                (.requiredOptionally, .var):        adjective = "Optionally Required"

        default:                                    adjective = nil
        }

        if  let adjective:String
        {
            html[.span, { $0.class = "customization" }] = adjective
            html += " \(noun)"
        }
        else
        {
            html += noun
        }
    }
}
