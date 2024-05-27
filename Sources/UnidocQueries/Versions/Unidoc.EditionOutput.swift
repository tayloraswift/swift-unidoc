import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct EditionOutput:Sendable
    {
        public
        let package:PackageMetadata
        public
        let edition:EditionMetadata?

        @inlinable public
        init(package:PackageMetadata, edition:EditionMetadata?)
        {
            self.package = package
            self.edition = edition
        }
    }
}
extension Unidoc.EditionOutput:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case package
        case edition
    }
}
extension Unidoc.EditionOutput:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(package: try bson[.package].decode(), edition: try bson[.edition]?.decode())
    }
}
