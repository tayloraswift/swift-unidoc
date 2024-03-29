import BSON
import MongoQL
import UnidocDB

extension Unidoc.BuildEditionQuery
{
    struct Output:Sendable
    {
        let package:Unidoc.PackageMetadata
        let edition:Unidoc.EditionMetadata

        init(package:Unidoc.PackageMetadata, edition:Unidoc.EditionMetadata)
        {
            self.package = package
            self.edition = edition
        }
    }
}
extension Unidoc.BuildEditionQuery.Output:Mongo.MasterCodingModel
{
    enum CodingKey:String, Sendable
    {
        case package
        case edition
    }
}
extension Unidoc.BuildEditionQuery.Output:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            edition: try bson[.edition].decode())
    }
}
