import BSONDecoding
import BSONEncoding
import MarkdownABI
import Signatures
import SymbolGraphs
import Unidoc

extension Volume
{
    @frozen public
    enum Group:Equatable, Sendable
    {
        case  automatic (Automatic)
        case `extension`(Extension)
        case  topic(Topic)
    }
}
extension Volume.Group
{
    @frozen public
    enum CodingKey:String
    {
        /// Always present.
        case id = "_id"

        /// Optional and appears in ``Extension`` only. The field contains a list of
        /// constraints, which contain scalars.
        case conditions = "g"

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
        /// Optional and appears in ``Extension`` only.
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

        /// A database-internal flag indicating if this group originates from the latest
        /// release version of its package. Practically, this determines if extensions are
        /// visible outside of their native volume.
        ///
        /// ``Volume.Group`` doesn’t encode this directly, the ``Records.Groups.Element``
        /// view abstraction adds it after delegating to ``Volume.Group``’s ``encode(to:)``
        /// witness.
        case latest = "L"
    }
}
extension Volume.Group:Identifiable
{
    @inlinable public
    var id:Unidoc.Scalar
    {
        switch self
        {
        case .automatic(let group): return group.id
        case .extension(let group): return group.id
        case .topic(let group):     return group.id
        }
    }
}
extension Volume.Group:BSONDocumentEncodable
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
        case .automatic(let self):
            bson[.scope] = self.scope
            bson[.members] = self.members.isEmpty ? nil : self.members

            zones.update(with: self.members)

        case .extension(let self):
            bson[.conditions] = self.conditions.isEmpty ? nil : self.conditions
            bson[.culture] = self.culture
            bson[.scope] = self.scope

            bson[.conformances] = self.conformances.isEmpty ? nil : self.conformances
            bson[.features] = self.features.isEmpty ? nil : self.features
            bson[.nested] = self.nested.isEmpty ? nil : self.nested
            bson[.subforms] = self.subforms.isEmpty ? nil : self.subforms

            bson[.prefetch] = self.prefetch.isEmpty ? nil : self.prefetch

            bson[.overview] = self.overview
            bson[.details] = self.details

            zones.update(with: self.culture.zone)

            zones.update(with: self.conformances)
            zones.update(with: self.features)
            //  not sure if this is needed, nested decls should always be in the same zone as
            //  their culture.
            zones.update(with: self.nested)
            zones.update(with: self.subforms)
            zones.update(with: self.prefetch)

            zones.update(with: self.conditions)

        case .topic(let self):
            bson[.culture] = self.culture
            bson[.scope] = self.scope

            bson[.prefetch] = self.prefetch.isEmpty ? nil : self.prefetch

            bson[.overview] = self.overview
            bson[.members] = self.members.isEmpty ? nil : self.members

            zones.update(with: self.culture?.zone)
            zones.update(with: self.prefetch)
        }

        bson[.zones] = zones.ordered.isEmpty ? nil : zones.ordered
    }
}
extension Volume.Group:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let id:Unidoc.Scalar = try bson[.id].decode()
        switch id.plane
        {
        case .topic?:
            self = .topic(.init(id: id,
                culture: try bson[.culture]?.decode(),
                scope: try bson[.scope]?.decode(),
                prefetch: try bson[.prefetch]?.decode() ?? [],
                overview: try bson[.overview]?.decode(),
                members: try bson[.members]?.decode() ?? []))

        case .extension?:
            self = .extension(.init(id: id,
                conditions: try bson[.conditions]?.decode() ?? [],
                culture: try bson[.culture].decode(),
                scope: try bson[.scope].decode(),
                conformances: try bson[.conformances]?.decode() ?? [],
                features: try bson[.features]?.decode() ?? [],
                nested: try bson[.nested]?.decode() ?? [],
                subforms: try bson[.subforms]?.decode() ?? [],
                prefetch: try bson[.prefetch]?.decode() ?? [],
                overview: try bson[.overview]?.decode(),
                details: try bson[.details]?.decode()))

        case _:
            self = .automatic(.init(id: id,
                scope: try bson[.scope].decode(),
                members: try bson[.members]?.decode() ?? []))
        }
    }
}