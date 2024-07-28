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
        case feature                (FeatureRelationship)
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
        case .conformance           (let relationship): relationship
        case .intrinsicWitness      (let relationship): relationship
        case .extension             (let relationship): relationship
        case .inheritance           (let relationship): relationship
        case .feature               (let relationship): relationship
        case .member                (let relationship): relationship
        case .override              (let relationship): relationship
        case .requirement           (let relationship): relationship
        }
    }

    @inlinable public
    var origin:Symbol.Decl? { self.existential.origin }
}
extension Symbol.AnyRelationship:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
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
        let origin:Symbol.Decl? = try json[.origin]?.decode(as: SourceOrigin.self,
            with: \.resolution)

        switch try json[.type].decode(to: Keyword.self)
        {
        case .conformance:
            self = .conformance(.init(
                of: try json[.source].decode(),
                to: try json[.target].decode(),
                where: try json[.conditions]?.decode(),
                origin: origin))

        case .intrinsicWitness:
            self = .intrinsicWitness(.init(
                _ : try json[.source].decode(),
                of: try json[.target].decode(),
                origin: origin))
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
                origin: origin))
            try json[.conditions]?.decode(to: Never.self)

        case .membership:
            let source:Symbol.USR = try json[.source].decode()
            let target:Symbol.USR = try json[.target].decode()

            switch source
            {
            case .vector(let id):   self = .feature(.init(id, in: target, origin: origin))
            case .scalar(let id):   self = .member(.init(id, in: target, origin: origin))
            case .block(let id):    throw Symbol.MembershipError.invalid(member: id)
            }

            try json[.conditions]?.decode(to: Never.self)

        case .optionalRequirement:
            self = .requirement(.init(
                _ : try json[.source].decode(),
                of: try json[.target].decode(),
                origin: origin,
                optional: true))
            try json[.conditions]?.decode(to: Never.self)

        case .override:
            self = .override(.init(
                _ : try json[.source].decode(),
                of: try json[.target].decode(),
                origin: origin))
            try json[.conditions]?.decode(to: Never.self)

        case .requirement:
            self = .requirement(.init(
                _ : try json[.source].decode(),
                of: try json[.target].decode(),
                origin: origin))
            try json[.conditions]?.decode(to: Never.self)
        }
    }
}
