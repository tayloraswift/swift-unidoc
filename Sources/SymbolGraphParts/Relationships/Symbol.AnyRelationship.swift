import JSONDecoding
import Symbols

extension Symbol
{
    @frozen public
    enum AnyRelationship:Equatable, Hashable, Sendable
    {
        case conformance            (ConformanceRelationship)
        case intrinsicWitness       (IntrinsicWitnessRelationship)
        case `extension`            (ExtensionRelationship)
        case inheritance            (InheritanceRelationship)
        case member                 (MemberRelationship)
        case override               (OverrideRelationship)
        case requirement            (RequirementRelationship)
    }
}
extension Symbol.AnyRelationship
{
    @inlinable public
    var existential:any SymbolRelationship
    {
        switch self
        {
        case .conformance           (let relationship): return relationship
        case .intrinsicWitness      (let relationship): return relationship
        case .extension             (let relationship): return relationship
        case .inheritance           (let relationship): return relationship
        case .member                (let relationship): return relationship
        case .override              (let relationship): return relationship
        case .requirement           (let relationship): return relationship
        }
    }

    @inlinable public
    var origin:Symbol.Decl? { self.existential.origin }
}
extension Symbol.AnyRelationship:JSONObjectDecodable
{
    public
    enum CodingKey:String
    {
        case conditions = "swiftConstraints"
        case source
        case target
        case origin = "sourceOrigin"
        case type = "kind"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        switch try json[.type].decode(to: Keyword.self)
        {
        case .conformance:
            self = .conformance(.init(
                of: try json[.source].decode(),
                to: try json[.target].decode(),
                where: try json[.conditions]?.decode(),
                origin: try json[.origin]?.decode(as: SourceOrigin.self, with: \.resolution)))

        case .intrinsicWitness:
            self = .intrinsicWitness(.init(
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
            self = .member(.init(
                _ : try json[.source].decode(),
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
