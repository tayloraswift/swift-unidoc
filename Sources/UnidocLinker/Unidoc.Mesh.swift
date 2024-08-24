import JSON
import MD5
import Symbols
import UnidocRecords

extension Unidoc
{
    //  https://github.com/apple/swift/issues/71606
    @frozen public
    struct Mesh//:~Copyable
    {
        public
        let latestRelease:Edition?
        public
        let packageABI:MD5
        public
        let boundaries:[Boundary]
        public
        let metadata:VolumeMetadata

        @usableFromInline
        let interior:Interior

        init(latestRelease:Edition?,
            packageABI:MD5,
            boundaries:[Boundary],
            metadata:VolumeMetadata,
            interior:Interior)
        {
            self.latestRelease = latestRelease
            self.packageABI = packageABI
            self.boundaries = boundaries
            self.metadata = metadata
            self.interior = interior
        }
    }
}
extension Unidoc.Mesh
{
    @inlinable public
    var vertices:Vertices { self.interior.vertices }

    @inlinable public
    var groups:Groups { self.interior.groups }

    @inlinable public
    var index:JSON { self.interior.index }

    @inlinable public
    var trees:[Unidoc.TypeTree] { self.interior.trees }

    @inlinable public
    var volume:Symbol.Volume { self.metadata.symbol }
}
extension Unidoc.Mesh
{
    @inlinable public
    var id:Unidoc.Edition { self.metadata.id }
}
extension Unidoc.Mesh
{
    public
    func sitemap() -> Unidoc.Sitemap
    {
        .init(id: self.metadata.id.package,
            elements: .init(
                cultures: self.vertices.cultures,
                articles: self.vertices.articles,
                decls: self.vertices.decls))
    }
}
