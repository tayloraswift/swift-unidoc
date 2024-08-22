import HTML
import LexicalPaths
import MarkdownABI
import MarkdownRendering
import Signatures
import Symbols
import Unidoc
import UnidocDB
import UnidocRecords
import UnidocRender

extension Unidoc
{
    public
    class IdentifiablePageContext<Table> where Table:Unidoc.VertexContextTable
    {
        public
        let canonical:CanonicalVersion?

        private(set)
        var packages:PackageContext
        private
        var cache:Cache

        public
        let media:PackageMedia?

        /// This likely cannot be a `convenience` initializer due to
        /// <https://github.com/apple/swift/issues/73962>
        public required
        init(canonical:CanonicalVersion?,
            principal:VolumeMetadata,
            secondary:borrowing [VolumeMetadata],
            packages:__shared [PackageMetadata],
            vertices:Table)
        {
            let packages:PackageContext = .init(principal: principal.id.package,
                metadata: packages)
            let media:PackageMedia?

            if  let override:PackageMedia = packages.principal?.media
            {
                media = override
            }
            else if
                let repo:PackageRepo = packages.principal?.repo
            {
                let ref:String = principal.refname ?? repo.master ?? "master"
                let path:String
                switch repo.origin
                {
                case .github(let origin):   path = "/\(origin.owner)/\(origin.name)/\(ref)"
                }

                media = .init(prefix: "https://raw.githubusercontent.com\(path)",
                    webp: "https://media.githubusercontent.com/media\(path)")
            }
            else
            {
                media = nil
            }

            self.canonical = canonical
            self.packages = packages
            self.cache = .init(vertices: vertices,
                volumes: .init(principal: principal, secondary: secondary))
            self.media = media
        }

        public
        subscript(vertex id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.AnyVertex>?
        {
            self.cache[id]
        }

        public
        subscript(culture id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.CultureVertex>?
        {
            self.cache[culture: id]
        }

        public
        subscript(article id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.ArticleVertex>?
        {
            self.cache[article: id]
        }

        public
        subscript(decl id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.DeclVertex>?
        {
            self.cache[decl: id]
        }
    }
}
extension Unidoc.IdentifiablePageContext:Identifiable
{
    public final
    var id:Table.ID { self.cache.vertices.id }
}
extension Unidoc.IdentifiablePageContext:Unidoc.VertexContext
{
    public final
    var tooltips:Tooltips? { self.cache.tooltips }

    public final
    var vertices:Table { self.cache.vertices }

    public final
    var volume:Unidoc.VolumeMetadata { self.cache.volumes.principal }

    public final
    var repo:Unidoc.PackageRepo? { self.packages.principal?.repo }

    public
    subscript(package id:Unidoc.Package) -> Unidoc.PackageMetadata?
    {
        self.packages.metadata[id]
    }

    public final
    subscript(volume:Unidoc.Edition) -> Unidoc.VolumeMetadata?
    {
        self.cache.volumes[volume]
    }
}
extension Unidoc.IdentifiablePageContext
{
    public final
    subscript(secondary volume:Unidoc.Edition) -> Unidoc.VolumeMetadata?
    {
        self.cache.volumes.secondary[volume]
    }
}
