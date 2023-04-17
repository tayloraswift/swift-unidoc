import JSONDecoding
import JSONEncoding

enum SymbolRelationshipType:String, Equatable, Hashable, JSONDecodable, JSONEncodable, Sendable
{
    case conformance            = "conformsTo"
    case defaultImplementation  = "defaultImplementationOf"
    case `extension`            = "extensionTo"
    case membership             = "memberOf"
    case optionalRequirement    = "optionalRequirementOf"
    case override               = "overrides"
    case inheritance            = "inheritsFrom"
    case requirement            = "requirementOf"
}
