import HTML
import LexicalPaths
import MarkdownABI
import MarkdownRendering
import SwiftinitRender
import Symbols

extension Swiftinit.VertexPageContext
{
    @usableFromInline
    func vector<Display, Vector>(_ vector:Vector,
        display:Display) -> HTML.VectorLink<Display, Vector>?
        where Vector:Collection<Unidoc.Scalar>
    {
        vector.isEmpty ? nil : .init(self, display: display, scalars: vector)
    }
}
extension Swiftinit.VertexPageContext
{
    @usableFromInline
    func link(module:Unidoc.Scalar) -> HTML.Link<Symbol.Module>?
    {
        self[culture: module].map
        {
            .init(display: $0.module.id, target: $1)
        }
    }

    @usableFromInline
    func link(decl:Unidoc.Scalar) -> HTML.Link<UnqualifiedPath>?
    {
        guard
        let (decl, url):(Unidoc.DeclVertex, String?) = self[decl: decl],
        let path:UnqualifiedPath = .init(splitting: decl.stem)
        else
        {
            return nil
        }

        return .init(display: path, target: url)
    }

    @usableFromInline
    func link(article:Unidoc.Scalar) -> HTML.Link<Markdown.Bytecode.SafeView>?
    {
        self[article: article].map
        {
            .init(display: $0.headline.safe, target: $1)
        }
    }

    func link(file:Unidoc.Scalar, line:Int? = nil) -> Swiftinit.SourceLink?
    {
        guard
        let refname:String = self[file.edition]?.refname,
        case (let file, let origin?)? = self[file: file]
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
