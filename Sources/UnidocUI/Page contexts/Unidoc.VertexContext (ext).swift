import HTML
import LexicalPaths
import MarkdownABI
import MarkdownRendering
import UnidocRender
import Symbols

extension Unidoc.VertexContext
{
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
        let refname:String = self[file.edition]?.refname,
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
