import BSON
import MD5

extension Unidoc {
    /// We call this `EditionDependency` and not `VolumeDependency` because the target edition
    /// may not have an associated volume.
    @frozen public struct EditionDependency: Identifiable, Sendable {
        public let id: Edge<Edition>

        public let targetABI: MD5?
        public let targetChanged: Bool

        @inlinable init(id: Edge<Edition>, targetABI: MD5?, targetChanged: Bool) {
            self.id = id
            self.targetABI = targetABI
            self.targetChanged = targetChanged
        }
    }
}
extension Unidoc.EditionDependency {
    @inlinable public init(source: Unidoc.Edition, target: Unidoc.Edition, targetABI: MD5?) {
        self.init(
            id: .init(source: source, target: target),
            targetABI: targetABI,
            targetChanged: false
        )
    }
}
extension Unidoc.EditionDependency {
    @inlinable public var source: Unidoc.Edition { self.id.source }
    @inlinable public var target: Unidoc.Edition { self.id.target }
}
extension Unidoc.EditionDependency {
    @frozen public enum CodingKey: String, Sendable {
        case id = "_id"
        case targetABI = "B"
        case targetChanged = "C"
    }
}
extension Unidoc.EditionDependency: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.id] = self.id
        bson[.targetABI] = self.targetABI
        bson[.targetChanged] = self.targetChanged ? true : nil
    }
}
extension Unidoc.EditionDependency: BSONDocumentDecodable {
    public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            id: try bson[.id].decode(),
            targetABI: try bson[.targetABI]?.decode(),
            targetChanged: try bson[.targetChanged]?.decode() ?? false
        )
    }
}
