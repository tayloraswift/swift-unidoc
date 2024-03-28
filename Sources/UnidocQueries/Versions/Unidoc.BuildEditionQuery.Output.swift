import BSON
import MongoQL
import UnidocDB

extension Unidoc.BuildEditionQuery
{
    @frozen public
    struct Output:Sendable
    {
        public
        let package:Unidoc.PackageMetadata
        public
        let edition:Unidoc.EditionMetadata

        @inlinable
        init(package:Unidoc.PackageMetadata, edition:Unidoc.EditionMetadata)
        {
            self.package = package
            self.edition = edition
        }
    }
}
extension Unidoc.BuildEditionQuery.Output:Mongo.MasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case package
        case edition
    }
}
extension Unidoc.BuildEditionQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            edition: try bson[.edition].decode())
    }
}
