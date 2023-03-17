import JSONDecoding

@frozen public
struct SymbolRelationship:Equatable, Hashable, Sendable
{
    public
    let conditions:[GenericConstraint<SymbolIdentifier>]
    public
    let source:UnifiedSymbolResolution
    public
    let target:UnifiedSymbolResolution
    public
    let type:SymbolRelationshipType
    
    public
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
    public
    enum CodingKeys:String
    {
        case conditions = "swiftConstraints"
        case source
        case target
        case type = "kind"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(try json[.source].decode(),
            is: try json[.type].decode(),
            of: try json[.target].decode(),
            where: try json[.conditions]?.decode() ?? [])
    }
}
