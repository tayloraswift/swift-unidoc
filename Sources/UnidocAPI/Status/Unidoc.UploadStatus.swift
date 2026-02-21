import JSON
import Unidoc

extension Unidoc {
    @frozen public struct UploadStatus: Equatable, Sendable {
        public let edition: Edition
        /// Indicates if the uploaded snapshot replaced an existing snapshot.
        public let updated: Bool

        @inlinable public init(edition: Edition, updated: Bool) {
            self.edition = edition
            self.updated = updated
        }
    }
}
extension Unidoc.UploadStatus {
    @inlinable public var package: Unidoc.Package { self.edition.package }

    @inlinable public var version: Unidoc.Version { self.edition.version }
}
extension Unidoc.UploadStatus {
    @frozen public enum CodingKey: String, Sendable {
        case edition
        case updated
    }
}
extension Unidoc.UploadStatus: JSONObjectEncodable {
    public func encode(to json: inout JSON.ObjectEncoder<CodingKey>) {
        json[.edition] = self.edition
        json[.updated] = self.updated
    }
}
extension Unidoc.UploadStatus: JSONObjectDecodable {
    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        self.init(edition: try json[.edition].decode(), updated: try json[.updated].decode())
    }
}
