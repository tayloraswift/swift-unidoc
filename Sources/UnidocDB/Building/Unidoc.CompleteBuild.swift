import BSON
import MongoQL
import Symbols
import UnidocAPI
import UnidocRecords
import UnixTime

extension Unidoc {
    @frozen public struct CompleteBuild: Identifiable, Sendable {
        public let id: BuildIdentifier

        public let launched: UnixMillisecond
        public let finished: UnixMillisecond

        public let failure: BuildFailure?

        /// Used for display purposes only.
        public let name: Symbol.PackageAtRef

        public var logs: [BuildLogType]
        public var logsAreSecret: Bool

        @inlinable public init(
            id: BuildIdentifier,
            launched: UnixMillisecond,
            finished: UnixMillisecond,
            failure: BuildFailure?,
            name: Symbol.PackageAtRef,
            logs: [BuildLogType] = [],
            logsAreSecret: Bool = false
        ) {
            self.id = id
            self.launched = launched
            self.finished = finished
            self.failure = failure
            self.name = name
            self.logs = logs
            self.logsAreSecret = logsAreSecret
        }
    }
}
extension Unidoc.CompleteBuild: Mongo.MasterCodingModel {
    @frozen public enum CodingKey: String, Sendable, BSONDecodable {
        case id = "_id"
        case launched = "L"
        case finished = "F"
        case failure = "E"
        case name = "N"
        case logs = "O"
        case logsAreSecret = "A"

        case package = "p"
    }
}
extension Unidoc.CompleteBuild: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.id] = self.id
        bson[.launched] = self.launched
        bson[.finished] = self.finished
        bson[.failure] = self.failure
        bson[.name] = self.name
        bson[.logs] = self.logs.isEmpty ? nil : self.logs
        bson[.logsAreSecret] = self.logsAreSecret ? true : nil

        bson[.package] = self.id.edition.package
    }
}
extension Unidoc.CompleteBuild: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            id: try bson[.id].decode(),
            launched: try bson[.launched].decode(),
            finished: try bson[.finished].decode(),
            failure: try bson[.failure]?.decode(),
            name: try bson[.name].decode(),
            logs: try bson[.logs]?.decode() ?? [],
            logsAreSecret: try bson[.logsAreSecret]?.decode() ?? false
        )
    }
}
