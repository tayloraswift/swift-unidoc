import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct EditionState:Sendable
    {
        public
        let package:Unidoc.PackageMetadata
        public
        let version:Unidoc.VersionState

        init(package:Unidoc.PackageMetadata, version:Unidoc.VersionState)
        {
            self.package = package
            self.version = version
        }
    }
}
extension Unidoc.EditionState:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case package
        case version
    }
}
extension Unidoc.EditionState:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            version: try bson[.version].decode())
    }
}
