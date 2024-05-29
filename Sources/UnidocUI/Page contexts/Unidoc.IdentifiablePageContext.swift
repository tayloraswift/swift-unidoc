import HTML
import LexicalPaths
import MarkdownABI
import MarkdownRendering
import Signatures
import UnidocRender
import Symbols
import Unidoc
import UnidocDB
import UnidocRecords

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
extension Unidoc.IdentifiablePageContext
{
    /// Generates a subdomain header for a module using its shoot.
    final
    func subdomain(_ module:Unidoc.Route) -> Unidoc.VolumeMetadata.Subdomain?
    {
        let module:HTML.Link<Substring> = .init(display: module.stem.first,
            target: "\(Unidoc.DocsEndpoint[self.volume, module])")
        return .init(self.volume, culture: .original(module))
    }

    /// Generates a subdomain header for a module which is **not** the current principal vertex.
    ///
    /// This function returns nil if `culture` is the current principal vertex. To generate a
    /// subdomain header for the current principal vertex, use ``subdomain(_:)`` instead.
    final
    func subdomain(_ module:Substring,
        culture:Unidoc.Scalar) -> Unidoc.VolumeMetadata.Subdomain?
    {
        guard
        let url:String = self[culture: culture]?.target?.url
        else
        {
            return nil
        }

        let module:HTML.Link<Substring> = .init(display: module, target: url)
        return .init(self.volume, culture: .original(module))
    }

    final
    func subdomain(_ module:Substring,
        namespace:Unidoc.Scalar,
        culture:Unidoc.Scalar) -> Unidoc.VolumeMetadata.Subdomain?
    {
        guard culture != namespace
        else
        {
            return self.subdomain(module, culture: culture)
        }

        guard
        let namespace:String = self[culture: culture]?.target?.url,
        let culture:HTML.Link<Symbol.Module> = self.link(module: culture)
        else
        {
            return nil
        }

        let module:HTML.Link<Substring> = .init(display: module, target: namespace)
        return .init(self.volume, culture: .colonial(module, culture))
    }

    final
    var domain:Unidoc.VolumeMetadata.Domain { .init(self.volume) }
}
