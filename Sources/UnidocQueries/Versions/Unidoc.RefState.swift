import BSON
import MongoQL
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct RefState:Sendable
    {
        public
        let package:PackageMetadata
        public
        let version:VersionState
        public
        let build:PendingBuild?
        public
        let built:CompleteBuild?
        public
        let owner:User?

        init(package:PackageMetadata,
            version:VersionState,
            build:PendingBuild?,
            built:CompleteBuild?,
            owner:User?)
        {
            self.package = package
            self.version = version
            self.build = build
            self.built = built
            self.owner = owner
        }
    }
}
extension Unidoc.RefState
{
    @inlinable public
    var symbol:Symbol.PackageAtRef
    {
        .init(package: self.package.symbol, ref: self.version.edition.name)
    }
}
extension Unidoc.RefState:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case package
        case version
        case build
        case built
        case owner
    }
}
extension Unidoc.RefState:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            version: try bson[.version].decode(),
            build: try bson[.build]?.decode(),
            built: try bson[.built]?.decode(),
            owner: try bson[.owner]?.decode())
    }
}
