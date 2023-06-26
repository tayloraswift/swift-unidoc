import JSONDecoding
import Symbols

@frozen public
enum SymbolRelationship:Equatable, Hashable, Sendable
{
    case conformance            (Conformance)
    case defaultImplementation  (DefaultImplementation)
    case `extension`            (Extension)
    case inheritance            (Inheritance)
    case membership             (Membership)
    case override               (Override)
    case requirement            (Requirement)
}
extension SymbolRelationship
{
    @inlinable public
    var origin:Symbol.Decl?
    {
        switch self
        {
        case .conformance           (let relationship): return relationship.origin
        case .defaultImplementation (let relationship): return relationship.origin
        case .extension:                                return nil
        case .inheritance           (let relationship): return relationship.origin
        case .membership            (let relationship): return relationship.origin
        case .override              (let relationship): return relationship.origin
        case .requirement           (let relationship): return relationship.origin
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
                where: try json[.conditions]?.decode(),
                origin: try json[.origin]?.decode(as: SourceOrigin.self, with: \.resolution)))

        case .defaultImplementation:
            self = .defaultImplementation(.init(
                _ : try json[.source].decode(),
                of: try json[.target].decode(),
                origin: try json[.origin]?.decode(as: SourceOrigin.self, with: \.resolution)))
            try json[.conditions]?.decode(to: Never.self)

        case .extension:
            self = .extension(.init(
                _ : try json[.source].decode(),
                of: try json[.target].decode()))
            //  We cannot enforce the non-existence of `origin` here, because
            //  Foundation actually has extension blocks with source origins!
            //  An example of such a block is `s:e:s:SS5IndexV10FoundationEyABSicfc`,
            //  (``String.Index``) which has a source origin of `s:SK5IndexQa`
            //  (``BidirectionalCollection.Index``).
            //
            //  That doesn’t change the fact that such an edge is quite meaningless,
            //  so we must ignore it if it is present.
            try json[.conditions]?.decode(to: Never.self)

        case .inheritance:
            self = .inheritance(.init(
                by: try json[.source].decode(),
                of: try json[.target].decode(),
                origin: try json[.origin]?.decode(as: SourceOrigin.self, with: \.resolution)))
            try json[.conditions]?.decode(to: Never.self)

        case .membership:
            self = .membership(.init(
                of: try json[.source].decode(),
                in: try json[.target].decode(),
                origin: try json[.origin]?.decode(as: SourceOrigin.self, with: \.resolution)))
            try json[.conditions]?.decode(to: Never.self)

        case .optionalRequirement:
            self = .requirement(.init(
                _ : try json[.source].decode(),
                of: try json[.target].decode(),
                origin: try json[.origin]?.decode(as: SourceOrigin.self, with: \.resolution),
                optional: true))
            try json[.conditions]?.decode(to: Never.self)

        case .override:
            self = .override(.init(
                _ : try json[.source].decode(),
                of: try json[.target].decode(),
                origin: try json[.origin]?.decode(as: SourceOrigin.self, with: \.resolution)))
            try json[.conditions]?.decode(to: Never.self)

        case .requirement:
            self = .requirement(.init(
                _ : try json[.source].decode(),
                of: try json[.target].decode(),
                origin: try json[.origin]?.decode(as: SourceOrigin.self, with: \.resolution)))
            try json[.conditions]?.decode(to: Never.self)
        }
    }
}
