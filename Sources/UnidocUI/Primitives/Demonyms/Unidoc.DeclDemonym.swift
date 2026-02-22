import Symbols

extension Unidoc {
    struct DeclDemonym {
        let phylum: Phylum.Decl
        let kinks: Phylum.Decl.Kinks

        init(phylum: Phylum.Decl, kinks: Phylum.Decl.Kinks) {
            self.phylum = phylum
            self.kinks = kinks
        }
    }
}
extension Unidoc.DeclDemonym {
    var modifier: String? {
        if      self.kinks[is: .open] {
            "Open"
        } else if self.kinks[is: .required] {
            "Required"
        } else {
            nil
        }
    }

    var title: String {
        switch self.phylum {
        case .actor:                "Actor"
        case .associatedtype:       "Associated Type"
        case .case:                 "Enumeration Case"
        case .class:                "Class"
        case .deinitializer:        "Deinitializer"
        case .enum:                 "Enumeration"
        case .func(nil):            "Global Function"
        case .func(.class):         "Class Method"
        case .func(.instance):      "Instance Method"
        case .func(.static):        "Static Method"
        case .initializer:          "Initializer"
        case .macro(.freestanding): "Freestanding Macro"
        case .macro(.attached):     "Attached Macro"
        case .operator:             "Operator"
        case .protocol:             "Protocol"
        case .struct:               "Structure"
        case .subscript(.class):    "Class Subscript"
        case .subscript(.instance): "Instance Subscript"
        case .subscript(.static):   "Static Subscript"
        case .typealias:            "Type Alias"
        case .var(nil):             "Global Variable"
        case .var(.class):          "Class Property"
        case .var(.instance):       "Instance Property"
        case .var(.static):         "Static Property"
        }
    }

    var phrase: String {
        let phrase: String =
        switch self.phylum {
        case .actor:                "an actor"
        case .associatedtype:       "an associated type"
        case .case:                 "an enum case"
        case .class:                "a class"
        case .deinitializer:        "a deinitializer"
        case .enum:                 "an enum"
        case .func(nil):            "a global function"
        case .func(.class):         "a class method"
        case .func(.instance):      "an instance method"
        case .func(.static):        "a static method"
        case .initializer:          "an initializer"
        case .macro(.freestanding): "a freestanding macro"
        case .macro(.attached):     "an attached macro"
        case .operator:             "an operator"
        case .protocol:             "a protocol"
        case .struct:               "a struct"
        case .subscript(.class):    "a class subscript"
        case .subscript(.instance): "an instance subscript"
        case .subscript(.static):   "a static subscript"
        case .typealias:            "a typealias"
        case .var(nil):             "a global variable"
        case .var(.class):          "a class property"
        case .var(.instance):       "an instance property"
        case .var(.static):         "a static property"
        }

        if      self.kinks[is: .required] {
            return "\(phrase) requirement"
        } else if self.kinks[is: .intrinsicWitness] {
            return "\(phrase) default implementation"
        } else {
            return phrase
        }
    }
}
