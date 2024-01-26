import BSON
import MarkdownABI
import Signatures
import SymbolGraphs
import Unidoc

extension Unidoc
{
    @frozen public
    enum AnyGroup:Equatable, Sendable
    {
        case  conformer(ConformerGroup)
        case `extension`(ExtensionGroup)
        case  intrinsic(IntrinsicGroup)
        case  polygonal(PolygonalGroup)
        case  topic(TopicGroup)
    }
}

extension Unidoc.AnyGroup
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        /// Always present.
        case id = "_id"

        case layer = "A"

        /// Optional and appears in ``ExtensionGroup`` only. The field contains a list of
        /// constraints, which contain scalars.
        case constraints = "g"

        /// Always present in ``ExtensionGroup``, optional in ``TopicGroup``, and contains a
        /// scalar.
        case culture = "c"
        /// Always present in ``ExtensionGroup``, optional otherwise, and contains a scalar.
        /// Usually doesn’t need a secondary lookup.
        case scope = "X"

        /// Optional and appears in ``ExtensionGroup`` only.
        /// The field contains a list of scalars.
        case conformances = "p"
        /// Optional and appears in ``ExtensionGroup`` only.
        /// The field contains a list of scalars.
        case features = "f"
        /// Optional and appears in ``ExtensionGroup`` only.
        /// The field contains a list of scalars.
        case nested = "n"
        /// Optional and appears in ``ExtensionGroup``.
        /// The field contains a list of scalars.
        case subforms = "s"

        /// Contains a list of scalars referenced by the overview passages
        /// of the various master records referenced in this extension.
        /// This field is a lookup optimization.
        @available(*, unavailable)
        case prefetch = "y"

        /// Contains a passage, which contains a list of outlines,
        /// each of which may contain a scalar.
        case overview = "o"
        /// Contains a passage, which contains a list of outlines,
        /// each of which may contain a scalar. Only appears in ``Extension``.
        case details = "d"
        /// Appears in ``PolygonalGroup``, ``IntrinsicGroup`` and ``TopicGroup``.
        /// In ``TopicGroup``, the field contains links, some of which are scalars.
        /// In ``PolygonalGroup`` and ``IntrinsicGroup`` the field contains scalars, all of
        /// which are, of course, scalars.
        case members = "t"

        /// Optional and appears in ``ConformingTypesGroup`` only.
        /// The field contains a list of scalars.
        case unconditional = "u"
        /// Optional and appears in ``ConformingTypesGroup`` only.
        /// The field contains a list of conforming types, which contain scalars.
        case conditional = "k"

        /// Contains a list of precomputed zones, as MongoDB cannot easily
        /// convert scalars to zones. This field will be computed and
        /// encoded if non-empty, but it will never be decoded.
        case zones = "z"

        @available(*, unavailable)
        case latest = "L"
        /// A database-internal flag indicating the realm of the package this group originates
        /// from, if the group belongs to a snapshot of the latest release version of that
        /// package. Practically, this determines if extensions are visible outside of their
        /// native volume.
        ///
        /// ``Unidoc.AnyGroup`` doesn’t encode this directly, the ``Unidoc.DB.Groups``
        /// type adds it after delegating to ``Unidoc.AnyGroup``’s ``encode(to:)`` witness.
        case realm = "R"
    }
}
extension Unidoc.AnyGroup:Identifiable
{
    @inlinable public
    var id:Unidoc.Group
    {
        switch self
        {
        case .conformer(let group):     group.id
        case .extension(let group):     group.id
        case .intrinsic(let group):     group.id
        case .polygonal(let group):     group.id
        case .topic(let group):         group.id
        }
    }
}
extension Unidoc.AnyGroup:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        //  Don’t exclude the extension’s own zone, in case we ever want it
        //  to appear somewhere outside of that zone.
        var zones:Unidoc.EditionSet = .init()

        switch self
        {
        case .conformer(let self):
            bson[.layer] = Unidoc.GroupLayer.protocols

            bson[.culture] = self.culture
            bson[.scope] = self.scope

            bson[.unconditional] = self.unconditional.isEmpty ? nil : self.unconditional
            bson[.conditional] = self.conditional.isEmpty ? nil : self.conditional

            zones.update(with: self.culture.edition)
            zones.update(with: self.unconditional)
            zones.update(with: self.conditional)

        case .extension(let self):
            bson[.constraints] = self.constraints.isEmpty ? nil : self.constraints
            bson[.culture] = self.culture
            bson[.scope] = self.scope

            bson[.conformances] = self.conformances.isEmpty ? nil : self.conformances
            bson[.features] = self.features.isEmpty ? nil : self.features
            bson[.nested] = self.nested.isEmpty ? nil : self.nested
            bson[.subforms] = self.subforms.isEmpty ? nil : self.subforms

            bson[.overview] = self.overview
            bson[.details] = self.details

            zones.update(with: self.culture.edition)

            zones.update(with: self.conformances)
            zones.update(with: self.features)
            //  not sure if this is needed, nested decls should always be in the same zone as
            //  their culture.
            zones.update(with: self.nested)
            zones.update(with: self.subforms)

            zones.update(with: self.constraints)

        case .intrinsic(let self):
            bson[.culture] = self.culture
            bson[.scope] = self.scope

            bson[.members] = self.members.isEmpty ? nil : self.members

            zones.update(with: self.culture.edition)
            zones.update(with: self.members)

        case .polygonal(let self):
            bson[.scope] = self.scope
            bson[.members] = self.members.isEmpty ? nil : self.members

            zones.update(with: self.members)

        case .topic(let self):
            bson[.culture] = self.culture
            bson[.scope] = self.scope

            bson[.overview] = self.overview
            bson[.members] = self.members.isEmpty ? nil : self.members

            zones.update(with: self.culture?.edition)
        }

        bson[.zones] = zones.ordered.isEmpty ? nil : zones.ordered
    }
}
extension Unidoc.AnyGroup:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let id:ID = try bson[.id].decode()
        switch id.plane
        {
        case .conformer?:
            self = .conformer(.init(id: id,
                culture: try bson[.culture].decode(),
                scope: try bson[.scope].decode(),
                unconditional: try bson[.unconditional]?.decode() ?? [],
                conditional: try bson[.conditional]?.decode() ?? []))

        case .extension?:
            self = .extension(.init(id: id,
                constraints: try bson[.constraints]?.decode() ?? [],
                culture: try bson[.culture].decode(),
                scope: try bson[.scope].decode(),
                conformances: try bson[.conformances]?.decode() ?? [],
                features: try bson[.features]?.decode() ?? [],
                nested: try bson[.nested]?.decode() ?? [],
                subforms: try bson[.subforms]?.decode() ?? [],
                overview: try bson[.overview]?.decode(),
                details: try bson[.details]?.decode()))

        case .intrinsic?:
            self = .intrinsic(.init(id: id,
                culture: try bson[.culture].decode(),
                scope: try bson[.scope].decode(),
                members: try bson[.members]?.decode() ?? []))

        case .polygon?:
            self = .polygonal(.init(id: id,
                scope: try bson[.scope].decode(),
                members: try bson[.members]?.decode() ?? []))

        case _:
            self = .topic(.init(id: id,
                culture: try bson[.culture]?.decode(),
                scope: try bson[.scope]?.decode(),
                overview: try bson[.overview]?.decode(),
                members: try bson[.members]?.decode() ?? []))
        }
    }
}
