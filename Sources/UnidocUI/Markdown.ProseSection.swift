import HTML
import MarkdownABI
import MarkdownDisplay
import MarkdownRendering
import SymbolGraphs
import Unidoc
import UnidocRecords
import URI

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
                let file:Unidoc.FileVertex = self.context[file: id]
                else
                {
                    return nil
                }

                return self.context.media?.link(media: file.symbol)

            default:
                return nil
            }

        case .link(https: let url, safe: let safe):
            switch attribute
            {
            case .href:
                if  safe
                {
                    attribute = .safelink
                }
                else
                {
                    attribute = .external
                }
                fallthrough

            case .external:
                return "https://\(url)"

            default:
                return nil
            }

        case .path(let display, let scalars):
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
                guard
                let target:Unidoc.LinkTarget = self.context[vertex: target]?.target
                else
                {
                    return nil
                }

                let fragment:URI.Fragment? = display.fragment.map
                {
                    .init(decoded: String.init($0))
                }

                switch (target.location, fragment)
                {
                case (let url?, nil):
                    return url

                case (let url?, let fragment?):
                    return "\(url)\(fragment)"

                case (nil, let fragment?):
                    return "\(fragment)"

                case (nil, nil):
                    return nil
                }

            //  This needs to be here for backwards compatibility with older symbol graphs.
            case .src:
                guard
                let file:Unidoc.FileVertex = self.context[file: target]
                else
                {
                    return nil
                }

                return self.context.media?.link(media: file.symbol)

            default:
                return nil
            }

        case .fragment(let text):
            return "\(URI.Fragment.init(decoded: text))"

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
            html[.a]
            {
                $0.target = "_blank"
                $0.href = "https://\(url)"

                $0[name: .rel] = safe ? """
                \(HTML.Attribute.Rel.external)
                """ :
                """
                \(HTML.Attribute.Rel.external) \
                \(HTML.Attribute.Rel.nofollow) \
                \(HTML.Attribute.Rel.noopener) \
                \(HTML.Attribute.Rel.google_ugc)
                """
            } = url

        case .path(let display, let vector):
            //  We never started using path outlines for inline file elements, so we don’t need
            //  any backwards compatibility adaptors here.
            guard
            let id:Unidoc.Scalar = vector.last
            else
            {
                html[.code] = "<empty codelink>"
                return
            }

            if  reference.card
            {
                html ?= self.context.card(id)
                return
            }

            switch SymbolGraph.Plane.of(id.citizen)
            {
            case .article?:
                guard
                let link:Unidoc.LinkReference<Unidoc.ArticleVertex> = self.context[article: id]
                else
                {
                    html[.code] = display.path
                    return
                }
                guard
                let target:Unidoc.LinkTarget = link.target
                else
                {
                    //  This is a broken link, but we can still render the display text.
                    //  This is our fault, not the documentation author’s.
                    html[.a] = link.vertex.headline.safe
                    return
                }

                let fragment:URI.Fragment? = display.fragment.map
                {
                    .init(decoded: String.init($0))
                }

                switch (target.location, fragment)
                {
                case (let url?, nil):
                    //  This is a link to another page.
                    html[.a] { $0.href = url } = link.vertex.headline.safe

                case (let url?, let fragment?):
                    //  This is a link to another page with a fragment.
                    html[.a] { $0.href = "\(url)\(fragment)" } = display.fragment

                case (nil, let fragment?):
                    //  This is a link to the current page with a fragment. We should use the
                    //  heading text as the display text.
                    html[.a] { $0.href = "\(fragment)" } = display.fragment

                case (nil, nil):
                    //  This is a link to the current page.
                    html[.a] = link.vertex.headline.safe
                }

            case .module?:
                guard
                let link:Unidoc.LinkReference<Unidoc.CultureVertex> = self.context[culture: id]
                else
                {
                    html[.code] = display.path
                    return
                }

                //  TODO: support URL fragment?
                html[.code] = link

            default:
                guard
                let components:Unidoc.LinkVector = .init(self.context,
                    display: display.vector,
                    scalars: vector)
                else
                {
                    html[.code] = display.path
                    return
                }

                //  TODO: support URL fragment?
                html[.code] = components
            }

        case .fragment(let text):
            html[.a] { $0.href = "\(URI.Fragment.init(decoded: text))" } = text

        case .fallback(text: let text):
            html[.code] = text
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

        case .path(let display, let path):
            let components:[Substring] = display.vector.suffix(path.count)
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

        case .fragment(let text):
            utf8 += text.utf8

        case .fallback(text: let text):
            utf8 += text.utf8
        }
    }
}
