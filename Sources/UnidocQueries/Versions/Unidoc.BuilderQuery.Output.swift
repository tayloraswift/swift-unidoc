import BSON
import MongoQL
import UnidocDB

extension Unidoc.BuilderQuery
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
extension Unidoc.BuilderQuery.Output:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case package
        case edition
    }
}
extension Unidoc.BuilderQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            edition: try bson[.edition].decode())
    }
}
