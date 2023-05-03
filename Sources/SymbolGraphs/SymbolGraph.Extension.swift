import BSONDecoding
import BSONEncoding
import Codelinks
import Generics

extension SymbolGraph
{
    @frozen public
    struct Extension
    {
        public
        let conditions:[GenericConstraint<ScalarAddress>]

        public
        var conformances:[ScalarAddress]
        /// Members the extended type inherits from other types via subclassing,
        /// protocol conformances, etc.
        public
        var features:[ScalarAddress]
        /// Declarations directly nested in the extended type. Everything that
        /// is lexically-scoped to the extended type, and was not inherited from
        /// another type goes in this set.
        public
        var nested:[ScalarAddress]

        public
        var article:Article?

        @inlinable public
        init(conformances:[ScalarAddress] = [],
            features:[ScalarAddress] = [],
            nested:[ScalarAddress] = [],
            where conditions:[GenericConstraint<ScalarAddress>] = [])
        {
            self.conditions = conditions

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
        case conformances = "C"
        case features = "F"
        case nested = "N"
        case article = "A"
    }
}
extension SymbolGraph.Extension:BSONDocumentEncodable, BSONEncodable, BSONFieldEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.conformances] = self.conformances.isEmpty ? nil : self.conformances
        bson[.features] = self.features.isEmpty ? nil : self.features
        bson[.nested] = self.nested.isEmpty ? nil : self.nested

        bson[.conditions] = self.conditions.isEmpty ? nil : self.conditions
        bson[.article] = self.article
    }
}
extension SymbolGraph.Extension:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(conformances: try bson[.conformances]?.decode() ?? [],
            features: try bson[.features]?.decode() ?? [],
            nested: try bson[.nested]?.decode() ?? [],
            where: try bson[.conditions]?.decode() ?? [])
        
        self.article = try bson[.article]?.decode()
    }
}
