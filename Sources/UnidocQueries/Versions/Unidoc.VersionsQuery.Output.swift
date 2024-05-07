import BSON
import MongoQL
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc.VersionsQuery
{
    @frozen public
    struct Output:Sendable
    {
        public
        var versions:Unidoc.Versions
        public
        var aliases:[Symbol.Package]
        public
        var package:Unidoc.PackageMetadata
        public
        var build:Unidoc.BuildMetadata?
        public
        var realm:Unidoc.RealmMetadata?
        public
        var user:Unidoc.User?

        @inlinable public
        init(versions:Unidoc.Versions,
            aliases:[Symbol.Package],
            package:Unidoc.PackageMetadata,
            build:Unidoc.BuildMetadata?,
            realm:Unidoc.RealmMetadata?,
            user:Unidoc.User?)
        {
            self.versions = versions
            self.aliases = aliases
            self.package = package
            self.build = build
            self.realm = realm
            self.user = user
        }
    }
}
extension Unidoc.VersionsQuery.Output:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case versions_list
        case versions_top
        case aliases
        case package
        case build
        case realm
        case user
    }
}
extension Unidoc.VersionsQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        var top:Unidoc.Versions.TopOfTree? = try bson[.versions_top]?.decode()

        if  let container:Unidoc.Versions.TopOfTree = top,
            case nil = container.graph,
            case nil = container.volume
        {
            top = nil
        }

        self.init(versions: .init(
                list: try bson[.versions_list]?.decode() ?? [],
                top: top),
            aliases: try bson[.aliases]?.decode() ?? [],
            package: try bson[.package].decode(),
            build: try bson[.build]?.decode(),
            realm: try bson[.realm]?.decode(),
            user: try bson[.user]?.decode())
    }
}
