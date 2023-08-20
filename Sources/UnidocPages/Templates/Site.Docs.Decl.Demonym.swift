import HTML
import Unidoc

extension Site.Docs.Decl
{
    struct Demonym
    {
        let phylum:Unidoc.Decl
        let kinks:Unidoc.Decl.Kinks

        init(phylum:Unidoc.Decl, kinks:Unidoc.Decl.Kinks)
        {
            self.phylum = phylum
            self.kinks = kinks
        }
    }
}
extension Site.Docs.Decl.Demonym:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        let kink:String?
        if      self.kinks[is: .open]
        {
            kink = "Open"
        }
        else if self.kinks[is: .required]
        {
            kink = "Required"
        }
        else
        {
            kink = nil
        }

        if  let kink:String
        {
            html[.span, { $0.class = "kink" }] = kink
            html += " "
        }

        switch self.phylum
        {
        case .actor:                html += "Actor"
        case .associatedtype:       html += "Associated Type"
        case .case:                 html += "Enumeration Case"
        case .class:                html += "Class"
        case .deinitializer:        html += "Deinitializer"
        case .enum:                 html += "Enumeration"
        case .func(nil):            html += "Global Function"
        case .func(.class):         html += "Class Method"
        case .func(.instance):      html += "Instance Method"
        case .func(.static):        html += "Static Method"
        case .initializer:          html += "Initializer"
        case .operator:             html += "Operator"
        case .protocol:             html += "Protocol"
        case .struct:               html += "Structure"
        case .subscript(.class):    html += "Class Subscript"
        case .subscript(.instance): html += "Instance Subscript"
        case .subscript(.static):   html += "Static Subscript"
        case .typealias:            html += "Type Alias"
        case .var(nil):             html += "Global Variable"
        case .var(.class):          html += "Class Property"
        case .var(.instance):       html += "Instance Property"
        case .var(.static):         html += "Static Property"
        }

        if  self.kinks[is: .intrinsicWitness]
        {
            html += " (Default Implementation)"
        }
    }
}
