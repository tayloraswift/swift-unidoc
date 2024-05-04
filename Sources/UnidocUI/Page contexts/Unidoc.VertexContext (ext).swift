import HTML
import LexicalPaths
import MarkdownABI
import MarkdownRendering
import UnidocRender
import Symbols

extension Unidoc.VertexContext
{
    func vector<Display, Vector>(_ vector:Vector,
        display:Display) -> HTML.VectorLink<Display, Vector>?
        where Vector:Collection<Unidoc.Scalar>
    {
        vector.isEmpty ? nil : .init(self, display: display, scalars: vector)
    }
}
extension Unidoc.VertexContext
{
    func card(decl id:Unidoc.Scalar) -> Unidoc.DeclCard?
    {
        guard
        let link:Unidoc.LinkReference<Unidoc.DeclVertex> = self[decl: id],
        let url:String = link.target?.location
        else
        {
            return nil
        }

        return .init(self, vertex: link.vertex, target: url)
    }

    func card(_ id:Unidoc.Scalar) -> Unidoc.AnyCard?
    {
        guard
        let link:Unidoc.LinkReference<Unidoc.AnyVertex> = self[vertex: id],
        let url:String = link.target?.location
        else
        {
            return nil
        }

        switch link.vertex
        {
        case .article(let vertex):  return .article(.init(self, vertex: vertex, target: url))
        case .culture(let vertex):  return .culture(.init(self, vertex: vertex, target: url))
        case .decl(let vertex):     return .decl(.init(self, vertex: vertex, target: url))
        case .product(let vertex):  return .product(.init(self, vertex: vertex, target: url))
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
            .init(display: $0.vertex.module.id, target: $0.target?.location)
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

        return .init(display: path, target: link.target?.location)
    }

    func link(source file:Unidoc.Scalar, line:Int? = nil) -> Unidoc.SourceLink?
    {
        guard
        let refname:String = self[file.edition]?.refname,
        let vertex:Unidoc.FileVertex = self[file: file],
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
