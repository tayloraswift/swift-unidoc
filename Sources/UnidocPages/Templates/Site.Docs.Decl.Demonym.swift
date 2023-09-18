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
extension Site.Docs.Decl.Demonym:CustomStringConvertible
{
    var description:String
    {
        var what:String
        switch self.phylum
        {
        case .actor:                what = "an actor"
        case .associatedtype:       what = "an associated type"
        case .case:                 what = "an enum case"
        case .class:                what = "a class"
        case .deinitializer:        what = "a deinitializer"
        case .enum:                 what = "an enum"
        case .func(nil):            what = "a global function"
        case .func(.class):         what = "a class method"
        case .func(.instance):      what = "an instance method"
        case .func(.static):        what = "a static method"
        case .initializer:          what = "an initializer"
        case .macro(.freestanding): what = "a freestanding macro"
        case .macro(.attached):     what = "an attached macro"
        case .operator:             what = "an operator"
        case .protocol:             what = "a protocol"
        case .struct:               what = "a struct"
        case .subscript(.class):    what = "a class subscript"
        case .subscript(.instance): what = "an instance subscript"
        case .subscript(.static):   what = "a static subscript"
        case .typealias:            what = "a typealias"
        case .var(nil):             what = "a global variable"
        case .var(.class):          what = "a class property"
        case .var(.instance):       what = "an instance property"
        case .var(.static):         what = "a static property"
        }

        if  self.kinks[is: .required]
        {
            what += " requirement"
        }
        else if self.kinks[is: .intrinsicWitness]
        {
            what += " default implementation"
        }

        return what
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
        case .macro(.freestanding): html += "Freestanding Macro"
        case .macro(.attached):     html += "Attached Macro"
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
