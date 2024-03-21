import HTML
import LexicalPaths
import MarkdownABI
import MarkdownRendering
import Signatures
import SwiftinitRender
import Symbols
import Unidoc
import UnidocDB
import UnidocRecords

extension Unidoc
{
    public
    class IdentifiablePageContext<VertexCacheType> where VertexCacheType:Unidoc.VertexCache
    {
        public
        let canonical:CanonicalVersion?

        private
        var cache:Cache

        public
        let repo:PackageRepo?

        init(canonical:CanonicalVersion?, cache:Cache, repo:Unidoc.PackageRepo?)
        {
            self.cache = cache
            self.repo = repo
            self.canonical = canonical
        }

        public convenience required
        init(canonical:CanonicalVersion?, vertices:Vertices, volumes:Volumes, repo:PackageRepo?)
        {
            self.init(canonical: canonical,
                cache: .init(
                    vertices: .form(from: consume vertices),
                    volumes: volumes),
                repo: repo)
        }

        public
        subscript(vertex id:Unidoc.Scalar) -> (vertex:Unidoc.AnyVertex, url:String?)?
        {
            self.cache[id]
        }

        public
        subscript(culture id:Unidoc.Scalar) -> (vertex:Unidoc.CultureVertex, url:String?)?
        {
            self.cache[culture: id]
        }

        public
        subscript(article id:Unidoc.Scalar) -> (vertex:Unidoc.ArticleVertex, url:String?)?
        {
            self.cache[article: id]
        }

        public
        subscript(decl id:Unidoc.Scalar) -> (vertex:Unidoc.DeclVertex, url:String?)?
        {
            self.cache[decl: id]
        }
    }
}
extension Unidoc.IdentifiablePageContext:Identifiable
{
    public final
    var id:VertexCacheType.ID { self.cache.vertices.id }
}
extension Unidoc.IdentifiablePageContext:Unidoc.VertexContext
{
    public final
    var volume:Unidoc.VolumeMetadata { self.cache.volumes.principal }

    public final
    subscript(secondary volume:Unidoc.Edition) -> Unidoc.VolumeMetadata?
    {
        self.cache.volumes.secondary[volume]
    }
    public final
    subscript(volume:Unidoc.Edition) -> Unidoc.VolumeMetadata?
    {
        self.cache.volumes[volume]
    }

    public final
    subscript(vertex:Unidoc.Scalar) -> Unidoc.AnyVertex?
    {
        self.cache.vertices[vertex]?.vertex
    }

    public final
    subscript(file id:Unidoc.Scalar) -> Unidoc.FileVertex?
    {
        self.cache.vertices[id]?.vertex.file
    }
}
extension Unidoc.IdentifiablePageContext
{
    /// Generates a subdomain header for a module using its shoot.
    final
    func subdomain(_ module:Unidoc.Route) -> Unidoc.VolumeMetadata.Subdomain?
    {
        let module:HTML.Link<Substring> = .init(display: module.stem.first,
            target: "\(Swiftinit.Docs[self.volume, module])")
        return .init(self.volume, culture: .original(module))
    }

    /// Generates a subdomain header for a module which is **not** the current principal vertex.
    ///
    /// This function returns nil is `culture` is the current principal vertex. To generate a
    /// subdomain header for the current principal vertex, use ``subdomain(_:)`` instead.
    final
    func subdomain(_ module:Substring,
        culture:Unidoc.Scalar) -> Unidoc.VolumeMetadata.Subdomain?
    {
        guard
        let url:String = self[culture: culture]?.url
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
        let namespace:String = self[culture: culture]?.url,
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
