import BSON
import SymbolGraphs
import Symbols

extension Unidoc
{
    @frozen public
    struct PackageMetadata:Identifiable, Sendable
    {
        /// The coordinate this package was assigned. All package coordinates are currently
        /// positive.
        ///
        /// Package coordinates cannot be used to distinguish any package characteristic that
        /// can change, because the coordinate can never change. Tracking a remote GitHub repo
        /// counts as something that can change.
        public
        let id:Package

        /// The current preferred name for this package. A package may have multiple names,
        /// and the preferred name can change.
        public
        var symbol:Symbol.Package

        /// Indicates whether this package is hidden from the public.
        public
        var hidden:Bool
        /// The current realm this package belongs to. A package can change realms, or lack one
        /// entirely.
        public
        var realm:Realm?
        /// Indicates if this package is currently undergoing realm alignment.
        public
        var realmAligning:Bool

        public
        var platformPreference:Triple?

        /// Overrides the default repo-based media origins. This is mostly used for previewing
        /// documentation locally.
        public
        var media:PackageMedia?
        /// The remote git repo this package tracks.
        ///
        /// Currently only GitHub repos are supported.
        public
        var repo:PackageRepo?

        @inlinable public
        init(id:Unidoc.Package,
            symbol:Symbol.Package,
            hidden:Bool = false,
            realm:Unidoc.Realm? = nil,
            realmAligning:Bool = false,
            platformPreference:Triple? = nil,
            media:PackageMedia? = nil,
            repo:PackageRepo? = nil)
        {
            self.id = id
            self.symbol = symbol
            self.hidden = hidden
            self.realm = realm
            self.realmAligning = realmAligning
            self.platformPreference = platformPreference
            self.media = media
            self.repo = repo
        }
    }
}
extension Unidoc.PackageMetadata
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case symbol = "Y"
        case hidden = "H"
        case realm = "r"
        case realmAligning = "A"
        case platformPreference = "O"
        case media = "M"
        case repo = "G"

        @available(*, unavailable)
        case repoLegacy = "R"

        @available(*, unavailable)
        case crawled = "C"
        @available(*, unavailable)
        case expires = "T"
    }
}
extension Unidoc.PackageMetadata:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.symbol] = self.symbol
        bson[.hidden] = self.hidden ? true : nil
        bson[.realm] = self.realm
        bson[.realmAligning] = self.realmAligning ? true : nil
        bson[.platformPreference] = self.platformPreference
        bson[.media] = self.media
        bson[.repo] = self.repo
    }
}
extension Unidoc.PackageMetadata:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            symbol: try bson[.symbol].decode(),
            hidden: try bson[.hidden]?.decode() ?? false,
            realm: try bson[.realm]?.decode(),
            realmAligning: try bson[.realmAligning]?.decode() ?? false,
            platformPreference: try bson[.platformPreference]?.decode(),
            media: try bson[.media]?.decode(),
            repo: try bson[.repo]?.decode())
    }
}
