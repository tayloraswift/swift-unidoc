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
    enum CodingKey:String
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
extension SymbolGraph.Extension:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.conditions] = self.conditions.isEmpty ? nil : self.conditions
        bson[.namespace] = self.culture == self.namespace ? nil : self.namespace
        bson[.culture] = self.culture

        bson[.conformances] = SymbolGraph.Buffer.init(elidingEmpty: self.conformances)
        bson[.features] = SymbolGraph.Buffer.init(elidingEmpty: self.features)
        bson[.nested] = SymbolGraph.Buffer.init(elidingEmpty: self.nested)

        bson[.article] = self.article
    }
}
extension SymbolGraph.Extension:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let culture:Int = try bson[.culture].decode()
        self.init(conditions: try bson[.conditions]?.decode() ?? [],
            namespace: try bson[.namespace]?.decode() ?? culture,
            culture: culture,
            conformances: try bson[.conformances]?.decode(
                as: SymbolGraph.Buffer.self, with: \.elements) ?? [],
            features: try bson[.features]?.decode(
                as: SymbolGraph.Buffer.self, with: \.elements) ?? [],
            nested: try bson[.nested]?.decode(
                as: SymbolGraph.Buffer.self, with: \.elements) ?? [])

        self.article = try bson[.article]?.decode()
    }
}
