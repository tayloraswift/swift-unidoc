import HTML
import MarkdownABI
import MarkdownDisplay
import MarkdownRendering
import SymbolGraphs
import Unidoc
import UnidocRecords

extension Markdown
{
    struct ProseSection
    {
        private
        let context:any Unidoc.VertexContext

        let bytecode:Markdown.Bytecode
        let outlines:[Unidoc.Outline]

        init(_ context:any Unidoc.VertexContext,
            bytecode:Markdown.Bytecode,
            outlines:[Unidoc.Outline])
        {
            self.context = context

            self.bytecode = bytecode
            self.outlines = outlines
        }
    }
}
extension Markdown.ProseSection
{
    init(_ context:any Unidoc.VertexContext, overview:Unidoc.Passage)
    {
        self.init(context, bytecode: overview.markdown, outlines: overview.outlines)
    }
}
extension Markdown.ProseSection:HTML.OutputStreamableMarkdown
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
        case .file(line: let line, let id):
            switch attribute
            {
            case .href:
                return self.context.link(source: id, line: line)?.target

            case .src:
                guard
                let vertex:Unidoc.FileVertex = self.context[file: id]
                else
                {
                    return nil
                }

                return self.context.link(media: vertex)

            default:
                return nil
            }

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
            //  We would never have a use for the display text when loading an attribute.
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

            //  This needs to be here for backwards compatibility with older symbol graphs.
            case .src:
                guard
                let vertex:Unidoc.FileVertex = self.context[file: target]
                else
                {
                    return nil
                }

                return self.context.link(media: vertex)

            default:
                return nil
            }

        case .fallback(text: _):
            return nil
        }
    }

    func load(_ reference:Int, into html:inout HTML.ContentEncoder)
    {
        let reference:Markdown.ProseReference = .init(reference)
        let index:Int = reference.index

        guard self.outlines.indices.contains(index)
        else
        {
            return
        }

        switch self.outlines[index]
        {
        case .file(line: let line, let id):
            html ?= self.context.link(source: id, line: line)

        case .link(https: let url, safe: let safe):
            html[.a] { $0.href = "https://\(url)"; $0.rel = safe ? nil : .nofollow } = url

        case .fallback(text: let text):
            html[.code] = text

        case .path(let stem, let path):
            //  We never started using path outlines for inline file elements, so we don’t need
            //  any backwards compatibility adaptors here.
            guard
            let id:Unidoc.Scalar = path.last
            else
            {
                html[.code] = "<empty codelink>"
                return
            }
            if  reference.card
            {
                html ?= self.context.card(id)
            }
            else if SymbolGraph.Plane.article.contains(id.citizen)
            {
                html ?= self.context.link(article: id)
            }
            else
            {
                //  Take the suffix of the stem, because it may include a module namespace,
                //  and we never render the module namespace, even if it was written in the
                //  codelink text.
                html[.code] = self.context.vector(path,
                    display: stem.split(separator: " ").suffix(path.count))
            }
        }
    }
}
extension Markdown.ProseSection:TextOutputStreamableMarkdown
{
    func load(_ reference:Int, into utf8:inout [UInt8])
    {
        let reference:Markdown.ProseReference = .init(reference)
        let index:Int = reference.index

        guard self.outlines.indices.contains(index)
        else
        {
            return
        }
        switch self.outlines[index]
        {
        case .file(line: let line, let id):
            guard
            let file:Unidoc.FileVertex = self.context[file: id]
            else
            {
                break
            }

            utf8 += file.symbol.last.utf8

            if  let line:Int = line
            {
                utf8 += ":\(line + 1)".utf8
            }

        case .link(https: let url, safe: true):
            utf8 += "https://\(url)".utf8

        case .link(https: _, safe: false):
            //  We are probably better off not printing the URL at all.
            return

        case .fallback(text: let text):
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
