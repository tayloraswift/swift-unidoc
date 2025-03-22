import BSON
import MongoQL
import SymbolGraphs
import Symbols

extension Unidoc.ActivityQuery
{
    @frozen public
    struct Featured<Article>:Sendable where Article:Sendable
    {
        public
        let package:Symbol.Package
        public
        let article:Article

        @inlinable public
        init(package:Symbol.Package, article:Article)
        {
            self.package = package
            self.article = article
        }
    }
}
extension Unidoc.ActivityQuery.Featured:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case package = "P"
        case article = "A"
    }
}
extension Unidoc.ActivityQuery.Featured:BSONDocumentEncodable, BSONEncodable
    where Article:BSONEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.package] = self.package
        bson[.article] = self.article
    }
}
extension Unidoc.ActivityQuery.Featured:BSONDocumentDecodable, BSONDecodable
    where Article:BSONDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            article: try bson[.article].decode())
    }
}
