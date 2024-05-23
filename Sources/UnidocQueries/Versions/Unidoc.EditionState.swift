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
        let package:PackageMetadata
        public
        let version:VersionState

        public
        let builds:[BuildMetadata]

        init(package:PackageMetadata, version:VersionState, builds:[BuildMetadata] = [])
        {
            self.package = package
            self.version = version
            self.builds = builds
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
        case builds
    }
}
extension Unidoc.EditionState:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            version: try bson[.version].decode(),
            builds: try bson[.builds]?.decode() ?? [])
    }
}
