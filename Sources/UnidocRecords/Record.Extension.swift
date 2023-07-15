import BSONDecoding
import BSONEncoding
import MarkdownABI
import Signatures
import SymbolGraphs
import Unidoc

extension Record
{
    @frozen public
    struct Extension:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        let conditions:[GenericConstraint<Unidoc.Scalar?>]
        public
        let culture:Unidoc.Scalar
        public
        let scope:Unidoc.Scalar

        public
        let conformances:[Unidoc.Scalar]
        public
        let features:[Unidoc.Scalar]
        public
        let nested:[Unidoc.Scalar]
        public
        let subforms:[Unidoc.Scalar]

        /// Additional scalars to prefetch when this extension is loaded.
        /// This is used to obtain the masters for passage referents in the
        /// overview passages of the actual declarations in this extension
        /// without having to perform an additional lookup phase.
        public
        let prefetch:[Unidoc.Scalar]

        @inlinable public
        init(id:Unidoc.Scalar,
            conditions:[GenericConstraint<Unidoc.Scalar?>],
            culture:Unidoc.Scalar,
            scope:Unidoc.Scalar,
            conformances:[Unidoc.Scalar] = [],
            features:[Unidoc.Scalar] = [],
            nested:[Unidoc.Scalar] = [],
            subforms:[Unidoc.Scalar] = [],
            prefetch:[Unidoc.Scalar] = [])
        {
            self.id = id

            self.conditions = conditions
            self.culture = culture
            self.scope = scope

            self.conformances = conformances
            self.features = features
            self.nested = nested
            self.subforms = subforms

            self.prefetch = prefetch
        }
    }
}
extension Record.Extension
{
    @frozen public
    enum CodingKey:String
    {
        case id = "_id"

        /// Contains a list of constraints, which contain scalars.
        case conditions = "g"
        /// Contains a scalar.
        case culture = "c"
        /// Contains a scalar (but usually doesn’t need a secondary lookup).
        case scope = "X"

        /// Contains a list of scalars.
        case conformances = "p"
        /// Contains a list of scalars.
        case features = "f"
        /// Contains a list of scalars.
        case nested = "n"
        /// Contains a list of scalars.
        case subforms = "d"

        /// Contains a list of scalars referenced by the overview passages
        /// of the various master records referenced in this extension.
        /// This field is a lookup optimization.
        case prefetch = "y"

        /// Contains a list of precomputed zones, as MongoDB cannot easily
        /// convert scalars to zones. This field will be computed and
        /// encoded if non-empty, but it will never be decoded.
        case zones = "z"
    }

    @inlinable public static
    subscript(key:CodingKey) -> BSON.Key { .init(key) }
}
extension Record.Extension:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id

        //  Don’t exclude the extension’s own zone, in case we ever want it
        //  to appear somewhere outside of that zone.
        var zones:Unidoc.ZoneSet = .init()

        bson[.conditions] = self.conditions.isEmpty ? nil : self.conditions
        bson[.culture] = self.culture
        bson[.scope] = self.scope

        bson[.conformances] = self.conformances.isEmpty ? nil : self.conformances
        bson[.features] = self.features.isEmpty ? nil : self.features
        bson[.nested] = self.nested.isEmpty ? nil : self.nested
        bson[.subforms] = self.subforms.isEmpty ? nil : self.subforms

        bson[.prefetch] = self.prefetch.isEmpty ? nil : self.prefetch

        zones.update(with: self.culture.zone)

        zones.update(with: self.conformances)
        zones.update(with: self.features)
        zones.update(with: self.nested)
        zones.update(with: self.subforms)
        zones.update(with: self.prefetch)

        zones.update(with: self.conditions)

        bson[.zones] = zones.ordered.isEmpty ? nil : zones.ordered
    }
}
extension Record.Extension:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            conditions: try bson[.conditions]?.decode() ?? [],
            culture: try bson[.culture].decode(),
            scope: try bson[.scope].decode(),
            conformances: try bson[.conformances]?.decode() ?? [],
            features: try bson[.features]?.decode() ?? [],
            nested: try bson[.nested]?.decode() ?? [],
            subforms: try bson[.subforms]?.decode() ?? [],
            prefetch: try bson[.prefetch]?.decode() ?? [])
    }
}
