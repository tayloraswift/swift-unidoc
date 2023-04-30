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
        var article:Article<Referent>?

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
        fatalError("unimplemented")
    }
}
