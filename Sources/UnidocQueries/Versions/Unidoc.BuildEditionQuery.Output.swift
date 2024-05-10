import BSON
import MongoQL
import UnidocDB

extension Unidoc.BuildEditionQuery
{
    struct Output:Sendable
    {
        let package:Unidoc.PackageMetadata
        let version:Unidoc.VersionState

        init(
            package:Unidoc.PackageMetadata,
            version:Unidoc.VersionState)
        {
            self.package = package
            self.version = version
        }
    }
}
extension Unidoc.BuildEditionQuery.Output:Mongo.MasterCodingModel
{
    enum CodingKey:String, Sendable
    {
        case package
        case version
    }
}
extension Unidoc.BuildEditionQuery.Output:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            version: try bson[.version].decode())
    }
}
