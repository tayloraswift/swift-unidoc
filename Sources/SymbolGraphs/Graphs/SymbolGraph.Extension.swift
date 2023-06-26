import BSONDecoding
import BSONEncoding
import Signatures

extension SymbolGraph
{
    @frozen public
    struct Extension:Equatable, Sendable
    {
        public
        let conditions:[GenericConstraint<Int32>]
        public
        let namespace:Int
        public
        let culture:Int

        public
        var conformances:[Int32]
        /// Members the extended type inherits from other types via subclassing,
        /// protocol conformances, etc.
        public
        var features:[Int32]
        /// Declarations directly nested in the extended type. Everything that
        /// is lexically-scoped to the extended type, and was not inherited from
        /// another type goes in this set.
        public
        var nested:[Int32]

        public
        var article:Article<Never>?

        @inlinable public
        init(conditions:[GenericConstraint<Int32>],
            namespace:Int,
            culture:Int,
            conformances:[Int32] = [],
            features:[Int32] = [],
            nested:[Int32] = [])
        {
            self.conditions = conditions
            self.namespace = namespace
            self.culture = culture

            self.conformances = conformances
            self.features = features
            self.nested = nested

            self.article = nil
        }
    }
}
extension SymbolGraph.Extension
{
    @frozen public
    enum CodingKeys:String
    {
        case conditions = "S"
        case namespace = "M"
        case culture = "C"

        case conformances = "P"
        case features = "F"
        case nested = "N"
        case article = "A"
    }
}
extension SymbolGraph.Extension:BSONDocumentEncodable, BSONEncodable, BSONWeakEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.conditions] = self.conditions.isEmpty ? nil : self.conditions
        bson[.namespace] = self.culture == self.namespace ? nil : self.namespace
        bson[.culture] = self.culture

        bson[.conformances] = self.conformances.isEmpty ? nil : self.conformances
        bson[.features] = self.features.isEmpty ? nil : self.features
        bson[.nested] = self.nested.isEmpty ? nil : self.nested

        bson[.article] = self.article
    }
}
extension SymbolGraph.Extension:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        let culture:Int = try bson[.culture].decode()
        self.init(conditions: try bson[.conditions]?.decode() ?? [],
            namespace: try bson[.namespace]?.decode() ?? culture,
            culture: culture,
            conformances: try bson[.conformances]?.decode() ?? [],
            features: try bson[.features]?.decode() ?? [],
            nested: try bson[.nested]?.decode() ?? [])

        self.article = try bson[.article]?.decode()
    }
}
