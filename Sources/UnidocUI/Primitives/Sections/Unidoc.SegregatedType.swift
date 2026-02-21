extension Unidoc {
    enum SegregatedType {
        case conformances
        case defaultImplementations
        case featuresOnType
        case featuresOnInstance
        case globals
        case macros
        case membersOnType
        case membersOnInstance
        case overriddenBy
        case protocols
        case restatedBy
        case subtypes
        case subclasses
        case types
        case typealiases
    }
}
extension Unidoc.SegregatedType: CustomStringConvertible {
    var description: String {
        switch self {
        case .conformances:             "Conformances"
        case .defaultImplementations:   "Default implementations"
        case .featuresOnType:           "Type features"
        case .featuresOnInstance:       "Instance features"
        case .globals:                  "Globals"
        case .macros:                   "Macros"
        case .membersOnType:            "Type members"
        case .membersOnInstance:        "Instance members"
        case .overriddenBy:             "Overridden by"
        case .protocols:                "Protocols"
        case .restatedBy:               "Restated by"
        case .subtypes:                 "Subtypes"
        case .subclasses:               "Subclasses"
        case .types:                    "Types"
        case .typealiases:              "Typealiases"
        }
    }
}
