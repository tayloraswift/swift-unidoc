import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc {
    @frozen public struct PackageDependent: Sendable {
        /// TODO: de-optionalize
        public let packageRef: String?
        public let package: Unidoc.PackageMetadata
        public let edition: Unidoc.EditionMetadata
        public let volume: Unidoc.VolumeMetadata?

        @inlinable public init(
            packageRef: String?,
            package: Unidoc.PackageMetadata,
            edition: Unidoc.EditionMetadata,
            volume: Unidoc.VolumeMetadata?
        ) {
            self.packageRef = packageRef
            self.package = package
            self.edition = edition
            self.volume = volume
        }
    }
}
extension Unidoc.PackageDependent: Mongo.MasterCodingModel {
    @frozen public enum CodingKey: String, Sendable {
        case packageRef
        case package
        case edition
        case volume
    }
}
extension Unidoc.PackageDependent: BSONDocumentDecodable {
    public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            packageRef: try bson[.packageRef]?.decode(),
            package: try bson[.package].decode(),
            edition: try bson[.edition].decode(),
            volume: try bson[.volume]?.decode()
        )
    }
}
