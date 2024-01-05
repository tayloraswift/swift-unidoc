import BSON
import MarkdownABI
import Signatures
import SymbolGraphs
import Unidoc

extension Unidoc
{
    @frozen public
    enum Group:Equatable, Sendable
    {
        case  conformers(ConformingTypesGroup)

        case `extension`(ExtensionGroup)
        case  polygonal(PolygonalGroup)
        case  topic(TopicGroup)
    }
}

extension Unidoc.Group
{
    @available(*, deprecated, renamed: "Unidoc.ExtensionGroup")
    public
    typealias Extension = Unidoc.ExtensionGroup

    @available(*, deprecated, renamed: "Unidoc.PolygonalGroup")
    public
    typealias Automatic = Unidoc.PolygonalGroup

    @available(*, deprecated, renamed: "Unidoc.PolygonalGroup")
    public
    typealias Polygon = Unidoc.PolygonalGroup

    @available(*, deprecated, renamed: "Unidoc.TopicGroup")
    public
    typealias Topic = Unidoc.TopicGroup

    @frozen public
    enum CodingKey:String, Sendable
    {
        /// Always present.
        case id = "_id"

        case layer = "A"

        /// Optional and appears in ``Extension`` only. The field contains a list of
        /// constraints, which contain scalars.
        case constraints = "g"

        /// Always present in ``Extension``, optional in ``Topic``, and contains a scalar.
        case culture = "c"
        /// Always present in ``Extension``, optional otherwise, and contains a scalar.
        /// Usually doesn’t need a secondary lookup.
        case scope = "X"

        /// Optional and appears in ``Extension`` only.
        /// The field contains a list of scalars.
        case conformances = "p"
        /// Optional and appears in ``Extension`` only.
        /// The field contains a list of scalars.
        case features = "f"
        /// Optional and appears in ``Extension`` only.
        /// The field contains a list of scalars.
        case nested = "n"
        /// Optional and appears in ``Extension`` or ``ConformingTypes``.
        /// The field contains a list of scalars.
        case subforms = "s"

        /// Contains a list of scalars referenced by the overview passages
        /// of the various master records referenced in this extension.
        /// This field is a lookup optimization.
        case prefetch = "y"

        /// Contains a passage, which contains a list of outlines,
        /// each of which may contain a scalar.
        case overview = "o"
        /// Contains a passage, which contains a list of outlines,
        /// each of which may contain a scalar. Only appears in ``Extension``.
        case details = "d"
        /// Appears in ``Automatic`` and ``Topic``. In ``Topic``, the field contains links,
        /// some of which are scalars. In ``Automatic`` the field contains scalars, all of
        /// which are, of course, scalars.
        case members = "t"

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
        /// ``Unidoc.Group`` doesn’t encode this directly, the ``UnidocDatabase.Groups``
        /// type adds it after delegating to ``Unidoc.Group``’s ``encode(to:)`` witness.
        case realm = "R"
    }
}
extension Unidoc.Group:Identifiable
{
    @inlinable public
    var id:ID
    {
        switch self
        {
        case .conformers(let group):    group.id
        case .extension(let group):     group.id
        case .polygonal(let group):     group.id
        case .topic(let group):         group.id
        }
    }
}
extension Unidoc.Group:BSONDocumentEncodable
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
        case .conformers(let self):
            bson[.layer] = Unidoc.GroupLayer.protocols

            bson[.constraints] = self.constraints.isEmpty ? nil : self.constraints
            bson[.culture] = self.culture
            bson[.scope] = self.scope

            //  This is the only array field and there is no reason why it would ever be empty.
            bson[.subforms] = self.types

            zones.update(with: self.culture.edition)
            zones.update(with: self.types)
            zones.update(with: self.constraints)

        case .extension(let self):
            bson[.layer] = Unidoc.GroupLayer.curations

            bson[.constraints] = self.constraints.isEmpty ? nil : self.constraints
            bson[.culture] = self.culture
            bson[.scope] = self.scope

            bson[.conformances] = self.conformances.isEmpty ? nil : self.conformances
            bson[.features] = self.features.isEmpty ? nil : self.features
            bson[.nested] = self.nested.isEmpty ? nil : self.nested
            bson[.subforms] = self.subforms.isEmpty ? nil : self.subforms

            bson[.prefetch] = self.prefetch.isEmpty ? nil : self.prefetch

            bson[.overview] = self.overview
            bson[.details] = self.details

            zones.update(with: self.culture.edition)

            zones.update(with: self.conformances)
            zones.update(with: self.features)
            //  not sure if this is needed, nested decls should always be in the same zone as
            //  their culture.
            zones.update(with: self.nested)
            zones.update(with: self.subforms)
            zones.update(with: self.prefetch)

            zones.update(with: self.constraints)

        case .polygonal(let self):
            bson[.layer] = Unidoc.GroupLayer.curations

            bson[.scope] = self.scope
            bson[.members] = self.members.isEmpty ? nil : self.members

            zones.update(with: self.members)

        case .topic(let self):
            bson[.layer] = Unidoc.GroupLayer.curations

            bson[.culture] = self.culture
            bson[.scope] = self.scope

            bson[.prefetch] = self.prefetch.isEmpty ? nil : self.prefetch

            bson[.overview] = self.overview
            bson[.members] = self.members.isEmpty ? nil : self.members

            zones.update(with: self.culture?.edition)
            zones.update(with: self.prefetch)
        }

        bson[.zones] = zones.ordered.isEmpty ? nil : zones.ordered
    }
}
extension Unidoc.Group:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let id:ID = try bson[.id].decode()
        switch id.plane
        {
        case .conformers?:
            self = .conformers(.init(id: id,
                constraints: try bson[.constraints]?.decode() ?? [],
                culture: try bson[.culture].decode(),
                scope: try bson[.scope].decode(),
                types: try bson[.subforms].decode()))

        case .extension?:
            self = .extension(.init(id: id,
                constraints: try bson[.constraints]?.decode() ?? [],
                culture: try bson[.culture].decode(),
                scope: try bson[.scope].decode(),
                conformances: try bson[.conformances]?.decode() ?? [],
                features: try bson[.features]?.decode() ?? [],
                nested: try bson[.nested]?.decode() ?? [],
                subforms: try bson[.subforms]?.decode() ?? [],
                prefetch: try bson[.prefetch]?.decode() ?? [],
                overview: try bson[.overview]?.decode(),
                details: try bson[.details]?.decode()))

        case .polygon?:
            self = .polygonal(.init(id: id,
                scope: try bson[.scope].decode(),
                members: try bson[.members]?.decode() ?? []))

        case _:
            self = .topic(.init(id: id,
                culture: try bson[.culture]?.decode(),
                scope: try bson[.scope]?.decode(),
                prefetch: try bson[.prefetch]?.decode() ?? [],
                overview: try bson[.overview]?.decode(),
                members: try bson[.members]?.decode() ?? []))
        }
    }
}
