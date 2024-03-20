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

@usableFromInline final
class IdentifiablePageContext<Vertices> where Vertices:Swiftinit.VertexCache
{
    private
    var cache:Cache

    @usableFromInline
    let repo:Unidoc.PackageRepo?

    init(cache:Cache, repo:Unidoc.PackageRepo?)
    {
        self.cache = cache
        self.repo = repo
    }
}
extension IdentifiablePageContext:Identifiable
{
    @usableFromInline internal
    var id:Vertices.ID { self.cache.vertices.id }
}
extension IdentifiablePageContext
{
    convenience
    init(vertices cache:consuming Vertices,
        volume:Unidoc.VolumeMetadata,
        repo:Unidoc.PackageRepo?)
    {
        self.init(
            cache: .init(vertices: cache, volumes: .init(principal: volume)),
            repo: repo)
    }
}
extension IdentifiablePageContext
{
    /// Generates a subdomain header for a module using its shoot.
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

    var domain:Unidoc.VolumeMetadata.Domain { .init(self.volume) }
}
extension IdentifiablePageContext:Unidoc.VertexContext
{
    @usableFromInline
    var volume:Unidoc.VolumeMetadata { self.cache.volumes.principal }

    @usableFromInline
    subscript(secondary volume:Unidoc.Edition) -> Unidoc.VolumeMetadata?
    {
        self.cache.volumes.secondary[volume]
    }
    @usableFromInline
    subscript(volume:Unidoc.Edition) -> Unidoc.VolumeMetadata?
    {
        self.cache.volumes[volume]
    }

    @usableFromInline
    subscript(vertex:Unidoc.Scalar) -> Unidoc.AnyVertex?
    {
        self.cache.vertices[vertex]?.vertex
    }

    @usableFromInline
    subscript(vertex id:Unidoc.Scalar) -> (vertex:Unidoc.AnyVertex, url:String?)?
    {
        self.cache[id]
    }

    @usableFromInline
    subscript(culture id:Unidoc.Scalar) -> (vertex:Unidoc.CultureVertex, url:String?)?
    {
        self.cache[culture: id]
    }

    @usableFromInline
    subscript(article id:Unidoc.Scalar) -> (vertex:Unidoc.ArticleVertex, url:String?)?
    {
        self.cache[article: id]
    }

    @usableFromInline
    subscript(decl id:Unidoc.Scalar) -> (vertex:Unidoc.DeclVertex, url:String?)?
    {
        self.cache[decl: id]
    }

    @usableFromInline
    subscript(file id:Unidoc.Scalar) -> Unidoc.FileVertex?
    {
        self.cache.vertices[id]?.vertex.file
    }
}
