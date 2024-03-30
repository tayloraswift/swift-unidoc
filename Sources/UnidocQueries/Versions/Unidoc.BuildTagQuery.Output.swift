import BSON
import MongoQL
import UnidocDB

extension Unidoc.BuildTagQuery
{
    struct Output:Sendable
    {
        let package:Unidoc.PackageMetadata
        let version:Unidoc.Versions.Tag

        init(package:Unidoc.PackageMetadata, version:Unidoc.Versions.Tag)
        {
            self.package = package
            self.version = version
        }
    }
}
extension Unidoc.BuildTagQuery.Output:Mongo.MasterCodingModel
{
    enum CodingKey:String, Sendable
    {
        case package
        case version
    }
}
extension Unidoc.BuildTagQuery.Output:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            version: try bson[.version].decode())
    }
}
