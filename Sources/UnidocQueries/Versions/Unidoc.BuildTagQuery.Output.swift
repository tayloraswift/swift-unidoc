import BSON
import MongoQL
import UnidocDB

extension Unidoc.BuildTagQuery
{
    @frozen public
    struct Output:Sendable
    {
        public
        let package:Unidoc.PackageMetadata
        public
        let version:Unidoc.Versions.Tag

        @inlinable
        init(package:Unidoc.PackageMetadata, version:Unidoc.Versions.Tag)
        {
            self.package = package
            self.version = version
        }
    }
}
extension Unidoc.BuildTagQuery.Output:Mongo.MasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case package
        case version
    }
}
extension Unidoc.BuildTagQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            version: try bson[.version].decode())
    }
}
