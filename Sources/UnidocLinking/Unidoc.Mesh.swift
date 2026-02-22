import JSON
import MD5
import Symbols
import UnidocRecords

extension Unidoc {
    //  https://github.com/apple/swift/issues/71606
    @frozen public struct Mesh/*:~Copyable*/ {
        public let latestRelease: Edition?
        public let packageABI: MD5
        public let boundaries: [Boundary]
        public let metadata: VolumeMetadata

        public let vertices: Vertices
        public let groups: Groups
        public let index: JSON
        public let trees: [TypeTree]
        public let redirects: [RedirectVertex]

        @inlinable public init(
            latestRelease: Edition?,
            packageABI: MD5,
            boundaries: [Boundary],
            metadata: VolumeMetadata,
            vertices: Vertices,
            groups: Groups,
            index: JSON,
            trees: [TypeTree],
            redirects: [RedirectVertex]
        ) {
            self.latestRelease = latestRelease
            self.packageABI = packageABI
            self.boundaries = boundaries
            self.metadata = metadata

            self.vertices = vertices
            self.groups = groups
            self.index = index
            self.trees = trees
            self.redirects = redirects
        }
    }
}
extension Unidoc.Mesh {
    @inlinable public var volume: Symbol.Volume { self.metadata.symbol }
    @inlinable public var id: Unidoc.Edition { self.metadata.id }
}
extension Unidoc.Mesh {
    public func sitemap() -> Unidoc.Sitemap {
        .init(
            id: self.metadata.id.package,
            elements: .init(
                cultures: self.vertices.cultures,
                articles: self.vertices.articles,
                decls: self.vertices.decls
            )
        )
    }
}
