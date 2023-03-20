import JSONDecoding
import JSONEncoding

@frozen public
enum SymbolRelationshipType:String, Equatable, Hashable, JSONDecodable, JSONEncodable, Sendable
{
    case conformer              = "conformsTo"
    case defaultImplementation  = "defaultImplementationOf"
    case `extension`            = "extensionTo"
    case member                 = "memberOf"
    case optionalRequirement    = "optionalRequirementOf"
    case override               = "overrides"
    case refinement             = "inheritsFrom"
    case requirement            = "requirementOf"
}
