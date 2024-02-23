import HTML
import MarkdownABI
import MarkdownRendering
import SymbolGraphs
import Unidoc
import UnidocRecords

struct ProseSection
{
    private
    let context:any Swiftinit.VertexPageContext

    let bytecode:Markdown.Bytecode
    let outlines:[Unidoc.Outline]

    init(_ context:any Swiftinit.VertexPageContext,
        bytecode:Markdown.Bytecode,
        outlines:[Unidoc.Outline])
    {
        self.context = context

        self.bytecode = bytecode
        self.outlines = outlines
    }
}
extension ProseSection
{
    init(_ context:any Swiftinit.VertexPageContext, passage:Unidoc.Passage)
    {
        self.init(context, bytecode: passage.markdown, outlines: passage.outlines)
    }
}
extension ProseSection:HTML.OutputStreamableMarkdown
{
    func load(_ reference:Int, for attribute:inout Markdown.Bytecode.Attribute) -> String?
    {
        guard self.outlines.indices.contains(reference)
        else
        {
            return nil
        }

        switch self.outlines[reference]
        {
        case .text(let text):
            return text

        case .link(https: let url, safe: let safe):
            switch attribute
            {
            case .href:
                if !safe
                {
                    attribute = .external
                }
                fallthrough

            case .external:
                return "https://\(url)"

            default:
                return nil
            }

        case .path(_, let scalars):
            guard
            let target:Unidoc.Scalar = scalars.last
            else
            {
                return nil
            }

            switch attribute
            {
            case .href:
                return self.context[vertex: target]?.url

            case .src:
                guard
                case (.file(let vertex), nil)? = self.context[vertex: target]
                else
                {
                    return nil
                }

                return self.context.link(media: vertex)

            default:
                return nil
            }
        }
    }

    func load(_ reference:Int, into html:inout HTML.ContentEncoder)
    {
        guard self.outlines.indices.contains(reference)
        else
        {
            return
        }

        switch self.outlines[reference]
        {
        case .link(https: let url, safe: let safe):
            html[.a] { $0.href = "https://\(url)"; $0.rel = safe ? nil : .nofollow } = url

        case .text(let text):
            html[.code] = text

        case .path(let stem, let scalars):
            if  let scalar:Unidoc.Scalar = scalars.first,
                SymbolGraph.Plane.article.contains(scalar.citizen)
            {
                html ?= self.context.link(article: scalar)
                return
            }

            //  Take the suffix of the stem, because it may include a module namespace,
            //  and we never render the module namespace, even if it was written in the
            //  codelink text.
            html[.code] = self.context.vector(scalars,
                display: stem.split(separator: " ").suffix(scalars.count))
        }
    }
}
extension ProseSection:TextOutputStreamableMarkdown
{
    func load(_ reference:Int, into utf8:inout [UInt8])
    {
        guard self.outlines.indices.contains(reference)
        else
        {
            return
        }
        switch self.outlines[reference]
        {
        case .link:
            //  No reason this should ever appear here.
            return

        case .text(let text):
            utf8 += text.utf8

        case .path(let stem, let scalars):
            let components:[Substring] = stem.split(separator: " ").suffix(scalars.count)
            var first:Bool = true
            for component:Substring in components
            {
                if  first
                {
                    first = false
                }
                else
                {
                    utf8.append(0x2E)
                }

                utf8 += component.utf8
            }
        }
    }
}
