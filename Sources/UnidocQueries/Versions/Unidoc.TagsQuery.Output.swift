import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc.TagsQuery
{
    @frozen public
    struct Output:Sendable
    {
        public
        var package:Unidoc.PackageMetadata
        public
        var tags:[Unidoc.VersionState]
        public
        var user:Unidoc.User?

        @inlinable public
        init(
            package:Unidoc.PackageMetadata,
            tags:[Unidoc.VersionState],
            user:Unidoc.User?)
        {
            self.package = package
            self.tags = tags
            self.user = user
        }
    }
}
extension Unidoc.TagsQuery.Output:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case package
        case tags
        case user
    }
}
extension Unidoc.TagsQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(package: try bson[.package].decode(),
            tags: try bson[.tags].decode(),
            user: try bson[.user]?.decode())
    }
}
