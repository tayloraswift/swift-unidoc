import JSONDecoding
import JSONEncoding
import Symbols

extension Symbol.AnyRelationship {
    enum Keyword: String, Equatable, Hashable, JSONDecodable, JSONEncodable, Sendable {
        case conformance            = "conformsTo"
        case intrinsicWitness       = "defaultImplementationOf"
        case `extension`            = "extensionTo"
        case membership             = "memberOf"
        case optionalRequirement    = "optionalRequirementOf"
        case override               = "overrides"
        case inheritance            = "inheritsFrom"
        case requirement            = "requirementOf"
    }
}
