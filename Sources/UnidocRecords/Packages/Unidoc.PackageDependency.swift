import BSON

extension Unidoc {
    @frozen public struct PackageDependency: Identifiable, Sendable {
        /// A nested document identifying the ``source`` and ``target`` packages.
        public let id: Edge<Package>
        /// The latest release version of the ``source`` package.
        public var dependent: Version
        /// A name identifying the version of the ``target`` package pinned by the latest
        /// release version of the ``source`` package.
        ///
        /// TODO: deoptionalize
        public var targetRef: String?

        @inlinable init(id: Edge<Package>, dependent: Version, targetRef: String?) {
            self.id = id
            self.dependent = dependent
            self.targetRef = targetRef
        }
    }
}
extension Unidoc.PackageDependency {
    @inlinable public init(source: Unidoc.Edition, target: Unidoc.Package, targetRef: String) {
        self.init(
            id: .init(source: source.package, target: target),
            dependent: source.version,
            targetRef: targetRef
        )
    }
}
extension Unidoc.PackageDependency {
    @inlinable public var source: Unidoc.Edition {
        .init(package: self.id.source, version: self.dependent)
    }
    @inlinable public var target: Unidoc.Package { self.id.target }
}
extension Unidoc.PackageDependency {
    @frozen public enum CodingKey: String, Sendable {
        case id = "_id"
        case source = "e"
        case targetRef = "R"
    }
}
extension Unidoc.PackageDependency: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.id] = self.id
        bson[.source] = self.source
        bson[.targetRef] = self.targetRef
    }
}
extension Unidoc.PackageDependency: BSONDocumentDecodable {
    public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        let source: Unidoc.Edition = try bson[.source].decode()
        self.init(
            id: try bson[.id].decode(),
            dependent: source.version,
            targetRef: try bson[.targetRef]?.decode()
        )
    }
}
