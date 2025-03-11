import HTML
import ISO
import LexicalPaths
import MarkdownABI
import MarkdownRendering
import Symbols
import UnidocRender
import UnixCalendar
import URI

extension Unidoc.VertexContext
{
    var structuredData:String
    {
        if  let tagged:Timestamp = self.volume.commit?.date?.timestamp
        {
            """
            {
            "@context": "https://schema.org",
            "@type": "Article",
            "datePublished": "\(tagged.date)"
            }
            """
        }
        else
        {
            """
            {
            "@context": "https://schema.org",
            "@type": "Article"
            }
            """
        }
    }

    func byline(_ locale:ISO.Locale) -> Unidoc.Byline?
    {
        guard
        let tagged:Timestamp = self.volume.commit?.date?.timestamp
        else
        {
            return nil
        }

        return .init(published: tagged, locale: locale)
    }

    func card(decl id:Unidoc.Scalar) -> Unidoc.DeclCard?
    {
        guard
        let reference:Unidoc.LinkReference<Unidoc.DeclVertex> = self[decl: id],
        let target:Unidoc.LinkTarget = reference.target
        else
        {
            return nil
        }

        return .init(self, vertex: reference.vertex, target: target)
    }

    func card(_ id:Unidoc.Scalar) -> Unidoc.AnyCard?
    {
        guard
        let reference:Unidoc.LinkReference<Unidoc.AnyVertex> = self[vertex: id],
        let target:Unidoc.LinkTarget = reference.target
        else
        {
            return nil
        }

        switch reference.vertex
        {
        case .article(let vertex):  return .article(.init(self, vertex: vertex, target: target))
        case .culture(let vertex):  return .culture(.init(self, vertex: vertex, target: target))
        case .decl(let vertex):     return .decl(.init(self, vertex: vertex, target: target))
        case .product(let vertex):  return .product(.init(self, vertex: vertex, target: target))
        default:                    return nil
        }
    }
}
extension Unidoc.VertexContext
{
    func link(module:Unidoc.Scalar) -> HTML.Link<Symbol.Module>?
    {
        self[culture: module].map
        {
            .init(display: $0.vertex.module.id, target: $0.target?.url)
        }
    }

    func link(decl:Unidoc.Scalar) -> HTML.Link<UnqualifiedPath>?
    {
        guard
        let link:Unidoc.LinkReference<Unidoc.DeclVertex> = self[decl: decl],
        let path:UnqualifiedPath = .init(splitting: link.vertex.stem)
        else
        {
            return nil
        }

        return .init(display: path, target: link.target?.url)
    }

    func link(source file:Unidoc.Scalar, line:Int? = nil) -> Unidoc.SourceLink?
    {
        guard
        let refname:String = self[file.edition]?.commit?.name,
        let vertex:Unidoc.FileVertex = self.vertices[file]?.vertex.file,
        let origin:Unidoc.PackageOrigin = self.repo?.origin
        else
        {
            return nil
        }

        let icon:Unidoc.SourceLink.Icon
        let blob:String

        switch origin
        {
        case .github(let origin):
            icon = .github
            blob = "\(origin.https)/blob/\(refname)/\(vertex.symbol)"
        }

        return .init(target: line.map { "\(blob)#L\($0 + 1)" } ?? blob,
            icon: icon,
            file: vertex.symbol.last,
            line: line)
    }
}
extension Unidoc.VertexContext
{
    func load(id:Unidoc.Scalar,
        fragment:Substring? = nil,
        href attribute:inout Markdown.Bytecode.Attribute) -> String?
    {
        guard
        let target:Unidoc.LinkTarget = self[vertex: id]?.target
        else
        {
            return nil
        }
        if  case .exported = target
        {
            attribute = .safelink
        }

        switch (target.url, fragment.map { URI.Fragment.init(decoded: String.init($0)) })
        {
        case (let url?, nil):
            return url

        case (let url?, let fragment?):
            return "\(url)\(fragment)"

        case (nil, let fragment?):
            return "\(fragment)"

        case (nil, nil):
            return "#"
        }
    }

    func load(id:Unidoc.Scalar, src _:inout Markdown.Bytecode.Attribute) -> String?
    {
        guard
        let file:Unidoc.FileVertex = self.vertices[id]?.vertex.file
        else
        {
            return nil
        }

        return self.media.link(media: file.symbol)
    }
}
