import JSONDecoding

struct SymbolRelationship:Equatable, Hashable, Sendable
{
    let conditions:[GenericConstraint<SymbolIdentifier>]
    let source:UnifiedSymbolResolution
    let target:UnifiedSymbolResolution
    let type:SymbolRelationshipType
    
    init(_ source:UnifiedSymbolResolution,
        is type:SymbolRelationshipType,
        of target:UnifiedSymbolResolution,
        where conditions:[GenericConstraint<SymbolIdentifier>] = [])
    {
        self.conditions = conditions
        self.source = source 
        self.target = target
        self.type = type
    }
}
extension SymbolRelationship:JSONObjectDecodable
{
    enum CodingKeys:String
    {
        case conditions = "swiftConstraints"
        case source
        case target
        case type = "kind"
    }

    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(try json[.source].decode(),
            is: try json[.type].decode(),
            of: try json[.target].decode(),
            where: try json[.conditions]?.decode() ?? [])
    }
}
