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
    /// Shared outlines, valid for the overview and details passages.
    var outlines:[Unidoc.Outline]

    private
    var cache:Cache

    let repo:Unidoc.PackageRepo?

    init(cache:Cache, repo:Unidoc.PackageRepo?)
    {
        self.outlines = []
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
    @available(*, deprecated)
    func prose(overview passage:Unidoc.Passage) -> ProseSection
    {
        .init(self, bytecode: passage.markdown, outlines: passage.outlines)
    }
    func prose(_ bytecode:Markdown.Bytecode) -> ProseSection
    {
        //  We need to use the shared outlines, and not the array from the passage
        //  record, lest we make a frameshift indexing error.
        .init(self, bytecode: bytecode, outlines: self.outlines)
    }

    func code(_ snippet:Signature<Unidoc.Scalar?>.Expanded) -> CodeSection
    {
        .init(self, bytecode: snippet.bytecode, scalars: snippet.scalars)
    }

    func card(_ id:Unidoc.Scalar) -> Swiftinit.AnyCard?
    {
        switch self[vertex: id]
        {
        case (.article(let vertex), let url?)?:
            .article(.init(self, vertex: vertex, target: url))

        case (.culture(let vertex), let url?)?:
            .culture(.init(self, vertex: vertex, target: url))

        case (.decl(let vertex), let url?)?:
            .decl(.init(self, vertex: vertex, target: url))

        case (.product(let vertex), let url?)?:
            .product(.init(self, vertex: vertex, target: url))

        default:
            nil
        }
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
extension IdentifiablePageContext:Swiftinit.VertexPageContext
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
    subscript(file id:Unidoc.Scalar) ->
    (
        vertex:Unidoc.FileVertex,
        origin:Unidoc.PackageOrigin?
    )?
    {
        self.cache.vertices[id]?.vertex.file.map { (vertex: $0, origin: self.repo?.origin) }
    }
}
