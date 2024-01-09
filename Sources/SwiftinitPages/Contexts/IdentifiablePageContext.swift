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
    var id:Vertices.ID { self.vertices.id }
}
extension IdentifiablePageContext
{
    var vertices:Vertices
    {
        _read   { yield  self.cache.vertices }
        _modify { yield &self.cache.vertices }
    }
    var volumes:Swiftinit.Volumes
    {
        _read   { yield  self.cache.volumes }
        _modify { yield &self.cache.volumes }
    }
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
    func constraints(
        _ constraints:[GenericConstraint<Unidoc.Scalar?>]) -> Swiftinit.ConstraintsList?
    {
        .init(self, constraints: constraints)
    }
}
extension IdentifiablePageContext
{
    func prose(overview passage:Unidoc.Passage) -> ProseSection
    {
        .init(self, bytecode: passage.markdown, outlines: passage.outlines)
    }
    func prose(_ bytecode:MarkdownBytecode) -> ProseSection
    {
        //  We need to use the shared outlines, and not the array from the passage
        //  record, lest we make a frameshift indexing error.
        .init(self, bytecode: bytecode, outlines: self.outlines)
    }

    func code(_ snippet:Signature<Unidoc.Scalar?>.Expanded) -> CodeSection
    {
        .init(self, bytecode: snippet.bytecode, scalars: snippet.scalars)
    }

    func card(_ scalar:Unidoc.Scalar) -> Swiftinit.GroupList.Card?
    {
        guard
        case (let vertex, let url?)? = self.cache[scalar]
        else
        {
            return nil
        }

        return .init(overview: vertex.overview.map(self.prose(overview:)),
            vertex: vertex,
            target: url)
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
        let url:String = self.url(culture)
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
        let namespace:String = self.url(namespace),
        let culture:HTML.Link<Symbol.Module> = self.link(module: culture)
        else
        {
            return nil
        }

        let module:HTML.Link<Substring> = .init(display: module, target: namespace)
        return .init(self.volume, culture: .colonial(module, culture))
    }

    var domain:Unidoc.VolumeMetadata.Domain { .init(self.volume) }



    func link(file:Unidoc.Scalar, line:Int? = nil) -> Swiftinit.SourceLink?
    {
        guard
        let refname:String = self.volumes[file.edition]?.refname,
        let origin:Unidoc.PackageRepo.AnyOrigin = self.repo?.origin,
        case (.file(let file), _)? = self.vertices[file]
        else
        {
            return nil
        }

        let icon:Swiftinit.SourceLink.Icon
        let blob:String

        switch origin
        {
        case .github(let origin):
            icon = .github
            blob = "\(origin.https)/blob/\(refname)/\(file.symbol)"
        }

        return .init(target: line.map { "\(blob)#L\($0 + 1)" } ?? blob,
            icon: icon,
            file: file.symbol.last,
            line: line)
    }
}
extension IdentifiablePageContext:Swiftinit.VertexPageContext
{
    @usableFromInline
    func link(module:Unidoc.Scalar) -> HTML.Link<Symbol.Module>?
    {
        self.cache[culture: module].map
        {
            .init(display: $0.module.id, target: $1)
        }
    }

    @usableFromInline
    func link(decl:Unidoc.Scalar) -> HTML.Link<UnqualifiedPath>?
    {
        guard
        let (decl, url):(Unidoc.DeclVertex, String?) = self.cache[decl: decl],
        let path:UnqualifiedPath = .init(splitting: decl.stem)
        else
        {
            return nil
        }

        return .init(display: path, target: url)
    }

    @usableFromInline
    func link(article:Unidoc.Scalar) -> HTML.Link<MarkdownBytecode.SafeView>?
    {
        self.cache[article: article].map
        {
            .init(display: $0.headline.safe, target: $1)
        }
    }

    @usableFromInline
    func vector<Display, Vector>(_ vector:Vector,
        display:Display) -> HTML.VectorLink<Display, Vector>?
        where Vector:Collection<Unidoc.Scalar>
    {
        vector.isEmpty ? nil : .init(self, display: display, scalars: vector)
    }

    @usableFromInline
    func url(_ scalar:Unidoc.Scalar) -> String?
    {
        self.cache[scalar]?.url
    }

    @usableFromInline
    var volume:Unidoc.VolumeMetadata { self.volumes.principal }

    @usableFromInline
    subscript(edition:Unidoc.Edition) -> Unidoc.VolumeMetadata?
    {
        self.volumes[edition]
    }
}
