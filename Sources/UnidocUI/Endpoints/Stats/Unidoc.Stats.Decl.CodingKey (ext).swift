import PieCharts
import UnidocRecords

extension Unidoc.Stats.Decl.CodingKey: Identifiable {
    public var id: String {
        switch self {
        case .functions:            "function"
        case .operators:            "operator"
        case .constructors:         "constructor"
        case .methods:              "method"
        case .subscripts:           "subscript"
        case .functors:             "functor"
        case .protocols:            "protocol"
        case .requirements:         "requirement"
        case .witnesses:            "witness"
        case .attachedMacros:       "macro attached"
        case .freestandingMacros:   "macro freestanding"
        case .structures:           "structure"
        case .classes:              "class"
        case .actors:               "actor"
        case .typealiases:          "typealias"
        }
    }
}
extension Unidoc.Stats.Decl.CodingKey: Pie.ChartKey {
    public var name: String {
        switch self {
        case .functions:            "global functions or variables"
        case .operators:            "operators"
        case .constructors:         "initializers, type members, or enum cases"
        case .methods:              "instance members"
        case .subscripts:           "instance subscripts"
        case .functors:             "functors"
        case .protocols:            "protocols"
        case .requirements:         "protocol requirements"
        case .witnesses:            "default implementations"
        case .attachedMacros:       "attached macros"
        case .freestandingMacros:   "freestanding macros"
        case .structures:           "structures"
        case .classes:              "classes"
        case .actors:               "actors"
        case .typealiases:          "typealiases"
        }
    }
}
