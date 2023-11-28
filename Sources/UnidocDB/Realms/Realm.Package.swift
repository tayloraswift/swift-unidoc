import BSONDecoding
import BSONEncoding
import MongoQL
import SymbolGraphs
import Symbols
import UnidocRecords
import UnixTime

@available(*, deprecated, renamed: "Realm.Package")
public
typealias PackageRecord = Realm.Package

extension Realm
{
    @frozen public
    struct Package:Identifiable, Equatable, Sendable
    {
        /// The coordinate this package was assigned. All package coordinates are currently
        /// positive.
        ///
        /// Package coordinates cannot be used to distinguish any package characteristic that
        /// can change, because the coordinate can never change. Tracking a remote GitHub repo
        /// counts as something that can change.
        public
        let id:Int32

        /// The current preferred name for this package. A package may have multiple names,
        /// and the preferred name can change.
        public
        var symbol:Symbol.Package

        /// The current realm this package belongs to. A package can change realms.
        public
        var realm:Realm

        /// The remote git repo this package tracks.
        ///
        /// Currently only GitHub repos are supported.
        public
        var repo:Repo?

        /// When this package *record* was last crawled. This is different from the time when
        /// the package itself was last updated.
        public
        var crawled:BSON.Millisecond

        @inlinable public
        init(id:Int32,
            symbol:Symbol.Package,
            realm:Realm,
            repo:Repo? = nil,
            crawled:BSON.Millisecond = 0)
        {
            self.id = id
            self.symbol = symbol
            self.realm = realm
            self.repo = repo
            self.crawled = crawled
        }
    }
}
extension Realm.Package:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case symbol = "Y"
        case realm = "r"
        case repo = "R"
        case crawled = "T"
    }
}
extension Realm.Package:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.symbol] = self.symbol
        bson[.realm] = self.realm
        bson[.repo] = self.repo
        bson[.crawled] = self.crawled
    }
}
extension Realm.Package:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            symbol: try bson[.symbol].decode(),
            realm: try bson[.realm].decode(),
            repo: try bson[.repo]?.decode(),
            crawled: try bson[.crawled]?.decode() ?? 0)
    }
}
