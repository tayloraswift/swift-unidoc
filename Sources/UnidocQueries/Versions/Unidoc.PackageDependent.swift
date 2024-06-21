import BSON
import MongoQL
import UnidocRecords
import UnidocDB

extension Unidoc
{
    @frozen public
    struct PackageDependent:Sendable
    {
        public
        let package:Unidoc.PackageMetadata
        public
        let edition:Unidoc.EditionMetadata
        public
        let volume:Unidoc.VolumeMetadata?

        @inlinable public
        init(
            package:Unidoc.PackageMetadata,
            edition:Unidoc.EditionMetadata,
            volume:Unidoc.VolumeMetadata?)
        {
            self.package = package
            self.edition = edition
            self.volume = volume
        }
    }
}
extension Unidoc.PackageDependent:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case package
        case edition
        case volume
    }
}
extension Unidoc.PackageDependent:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            edition: try bson[.edition].decode(),
            volume: try bson[.volume]?.decode())
    }
}
