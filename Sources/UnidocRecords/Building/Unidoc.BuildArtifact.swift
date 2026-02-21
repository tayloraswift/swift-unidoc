import BSON
import UnidocAPI

extension Unidoc {
    @frozen public struct BuildArtifact: Sendable {
        public let edition: Edition?
        public var outcome: Result<BuildPayload, BuildFailure>
        public var seconds: Int64
        public var logs: [BuildLog]
        public var logsAreSecret: Bool

        @inlinable public init(
            edition: Edition?,
            outcome: Result<BuildPayload, BuildFailure>,
            seconds: Int64 = 0,
            logs: [BuildLog] = [],
            logsAreSecret: Bool = false
        ) {
            self.edition = edition
            self.seconds = seconds
            self.outcome = outcome
            self.logs = logs
            self.logsAreSecret = logsAreSecret
        }
    }
}
extension Unidoc.BuildArtifact {
    @inlinable public var failure: Unidoc.BuildFailure? {
        switch self.outcome {
        case .success:              nil
        case .failure(let failure): failure
        }
    }
}
extension Unidoc.BuildArtifact {
    @frozen public enum CodingKey: String, Sendable {
        case edition = "e"
        case payload = "S"
        case failure = "F"
        case seconds = "D"
        case logs = "L"
        case logsAreSecret = "A"
    }
}
extension Unidoc.BuildArtifact: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.edition] = self.edition

        switch self.outcome {
        case .success(let snapshot):    bson[.payload] = snapshot
        case .failure(let failure):     bson[.failure] = failure
        }

        bson[.seconds] = self.seconds
        bson[.logs] = self.logs.isEmpty ? nil : self.logs
        bson[.logsAreSecret] = self.logsAreSecret
    }
}
extension Unidoc.BuildArtifact: BSONDocumentDecodable {
    public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        let outcome: Result<Unidoc.BuildPayload, Unidoc.BuildFailure>

        if  let payload: Unidoc.BuildPayload = try bson[.payload]?.decode() {
            outcome = .success(payload)
        } else {
            outcome = .failure(try bson[.failure].decode())
        }

        self.init(
            edition: try bson[.edition]?.decode(),
            outcome: outcome,
            seconds: try bson[.seconds].decode(),
            logs: try bson[.logs]?.decode() ?? [],
            logsAreSecret: try bson[.logsAreSecret].decode()
        )
    }
}
