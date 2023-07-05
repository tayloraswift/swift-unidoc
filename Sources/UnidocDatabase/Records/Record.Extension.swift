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

        @inlinable internal
        init(id:Unidoc.Scalar,
            conditions:[GenericConstraint<Unidoc.Scalar?>],
            culture:Unidoc.Scalar,
            scope:Unidoc.Scalar,
            conformances:[Unidoc.Scalar] = [],
            features:[Unidoc.Scalar] = [],
            nested:[Unidoc.Scalar] = [],
            subforms:[Unidoc.Scalar] = [])
        {
            self.id = id

            self.conditions = conditions
            self.culture = culture
            self.scope = scope

            self.conformances = conformances
            self.features = features
            self.nested = nested
            self.subforms = subforms
        }
    }
}
extension Record.Extension
{
    init(signature:DynamicLinker.ExtensionSignature,
        extension:DynamicLinker.Extension)
    {
        self.init(id: `extension`.id,
            conditions: signature.conditions,
            culture: signature.culture,
            scope: signature.extends,
            conformances: `extension`.conformances,
            features: `extension`.features,
            nested: `extension`.nested,
            subforms: `extension`.subforms)
    }
}
extension Record.Extension
{
    @frozen public
    enum CodingKeys:String
    {
        case id = "_id"

        case conditions = "C"
        case culture = "X"
        case scope = "R"

        case conformances = "P"
        case features = "F"
        case nested = "N"
        case subforms = "S"
    }

    static
    subscript(key:CodingKeys) -> BSON.Key { .init(key) }
}
extension Record.Extension:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.id] = self.id

        bson[.conditions] = self.conditions.isEmpty ? nil : self.conditions
        bson[.culture] = self.culture
        bson[.scope] = self.scope

        bson[.conformances] = self.conformances.isEmpty ? nil : self.conformances
        bson[.features] = self.features.isEmpty ? nil : self.features
        bson[.nested] = self.nested.isEmpty ? nil : self.nested
        bson[.subforms] = self.subforms.isEmpty ? nil : self.subforms
    }
}
extension Record.Extension:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            conditions: try bson[.conditions]?.decode() ?? [],
            culture: try bson[.culture].decode(),
            scope: try bson[.scope].decode(),
            conformances: try bson[.conformances]?.decode() ?? [],
            features: try bson[.features]?.decode() ?? [],
            nested: try bson[.nested]?.decode() ?? [],
            subforms: try bson[.subforms]?.decode() ?? [])
    }
}
