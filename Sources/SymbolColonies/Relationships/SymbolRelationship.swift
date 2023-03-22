import JSONDecoding

@frozen public
enum SymbolRelationship:Equatable, Hashable, Sendable
{
    case conformance            (Conformance,           origin:SymbolOrigin? = nil)
    case defaultImplementation  (DefaultImplementation, origin:SymbolOrigin? = nil)
    case `extension`            (Extension)
    case inheritance            (Inheritance,           origin:SymbolOrigin? = nil)
    case membership             (Membership,            origin:SymbolOrigin? = nil)
    case optionalRequirement    (OptionalRequirement,   origin:SymbolOrigin? = nil)
    case override               (Override,              origin:SymbolOrigin? = nil)
    case requirement            (Requirement,           origin:SymbolOrigin? = nil)
}
extension SymbolRelationship
{
    @inlinable public
    var origin:SymbolOrigin?
    {
        switch self
        {
        case    .conformance            (_, origin: let origin),
                .defaultImplementation  (_, origin: let origin),
                .inheritance            (_, origin: let origin),
                .membership             (_, origin: let origin),
                .optionalRequirement    (_, origin: let origin),
                .override               (_, origin: let origin),
                .requirement            (_, origin: let origin):
            return origin
        
        case    .extension:
            return nil
        }
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
        case origin = "sourceOrigin"
        case type = "kind"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        switch try json[.type].decode(to: SymbolRelationshipType.self)
        {
        case .conformance:
            self = .conformance(.init(
                    of: try json[.source].decode(),
                    to: try json[.target].decode(),
                    where: try json[.conditions]?.decode()),
                origin: try json[.origin]?.decode())
        
        case .defaultImplementation:
            self = .defaultImplementation(.init(
                    _ : try json[.source].decode(),
                    of: try json[.target].decode()),
                origin: try json[.origin]?.decode())
            try json[.conditions]?.decode(to: Never.self)
        
        case .extension:
            self = .extension(.init(
                _ : try json[.source].decode(),
                of: try json[.target].decode()))
            try json[.conditions]?.decode(to: Never.self)
            try json[.origin]?.decode(to: Never.self)
        
        case .inheritance:
            self = .inheritance(.init(
                    by: try json[.source].decode(),
                    of: try json[.target].decode()),
                origin: try json[.origin]?.decode())
            try json[.conditions]?.decode(to: Never.self)
        
        case .membership:
            self = .membership(.init(
                    of: try json[.source].decode(),
                    in: try json[.target].decode()),
                origin: try json[.origin]?.decode())
            try json[.conditions]?.decode(to: Never.self)
        
        case .optionalRequirement:
            self = .optionalRequirement(.init(
                    _ : try json[.source].decode(),
                    of: try json[.target].decode()),
                origin: try json[.origin]?.decode())
            try json[.conditions]?.decode(to: Never.self)
        
        case .override:
            self = .override(.init(
                    _ : try json[.source].decode(),
                    of: try json[.target].decode()),
                origin: try json[.origin]?.decode())
            try json[.conditions]?.decode(to: Never.self)
        
        case .requirement:
            self = .requirement(.init(
                    _ : try json[.source].decode(),
                    of: try json[.target].decode()),
                origin: try json[.origin]?.decode())
            try json[.conditions]?.decode(to: Never.self)
        }
    }
}
