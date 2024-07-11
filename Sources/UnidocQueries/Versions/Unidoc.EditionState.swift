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
        let build:BuildMetadata?
        public
        let owner:User?

        init(package:PackageMetadata, version:VersionState, build:BuildMetadata?, owner:User?)
        {
            self.package = package
            self.version = version
            self.build = build
            self.owner = owner
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
        case build
        case owner
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
            build: try bson[.build]?.decode(),
            owner: try bson[.owner]?.decode())
    }
}
