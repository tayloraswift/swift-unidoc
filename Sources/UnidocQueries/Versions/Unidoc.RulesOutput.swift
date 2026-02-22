import BSON
import MongoQL
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc {
    @frozen public struct RulesOutput: Sendable {
        public var package: Unidoc.PackageMetadata

        /// The users who have been granted edit permissions for the ``package``.
        public var editors: [Unidoc.User]
        /// The users who are members of the organization that owns the ``package``, if the
        /// package is associated with repo owned by an organization.
        public var members: [Unidoc.User]
        /// The user (or organization) that owns the ``package``, if it has an associated repo.
        public var owner: Unidoc.User?
        /// The user that is currently logged in.
        public var user: Unidoc.User?

        @inlinable public init(
            package: Unidoc.PackageMetadata,
            editors: [Unidoc.User],
            members: [Unidoc.User],
            owner: Unidoc.User?,
            user: Unidoc.User?
        ) {
            self.package = package
            self.editors = editors
            self.members = members
            self.owner = owner
            self.user = user
        }
    }
}
extension Unidoc.RulesOutput: Mongo.MasterCodingModel {
    @frozen public enum CodingKey: String, Sendable {
        case package

        case members
        case editors
        case owner
        case user
    }
}
extension Unidoc.RulesOutput: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            package: try bson[.package].decode(),
            editors: try bson[.editors].decode(),
            members: try bson[.members].decode(),
            owner: try bson[.owner]?.decode(),
            user: try bson[.user]?.decode()
        )
    }
}
