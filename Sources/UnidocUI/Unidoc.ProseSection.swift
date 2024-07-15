import HTML
import MarkdownABI
import MarkdownDisplay
import MarkdownRendering
import SymbolGraphs
import Unidoc
import UnidocRecords
import URI

extension Unidoc
{
    struct ProseSection
    {
        let bytecode:Markdown.Bytecode
        let outlines:[Outline]
        let context:any VertexContext

        init(
            bytecode:Markdown.Bytecode,
            outlines:[Outline],
            context:any VertexContext)
        {
            self.bytecode = bytecode
            self.outlines = outlines
            self.context = context
        }
    }
}
extension Unidoc.ProseSection
{
    init(overview:Unidoc.Passage, context:any Unidoc.VertexContext)
    {
        self.init(bytecode: overview.markdown, outlines: overview.outlines, context: context)
    }
}
extension Unidoc.ProseSection:HTML.OutputStreamableMarkdown
{
    func load(_ reference:Int, for type:inout Markdown.Bytecode.Attribute) -> String?
    {
        guard self.outlines.indices.contains(reference)
        else
        {
            return nil
        }

        switch self.outlines[reference]
        {
        case .fallback:
            return nil

        case .fragment(let text):
            return "\(URI.Fragment.init(decoded: text))"

        case .bare(line: _, let id):
            switch type
            {
            //  File links are not yet supported.
            case .href: return self.context.load(id: id, href: &type)
            case .src:  return self.context.load(id: id, src: &type)
            default:    return nil
            }

        case .path(let display, let scalars):
            //  We would never have a use for the display text when loading an attribute.
            guard
            let target:Unidoc.Scalar = scalars.last
            else
            {
                return nil
            }

            let fragment:Substring? = display.fragment

            switch type
            {
            case .href: return self.context.load(id: target, fragment: fragment, href: &type)
            //  This needs to be here for backwards compatibility with older symbol graphs.
            case .src:  return self.context.load(id: target, src: &type)
            default:    return nil
            }

        case .url(let url, safe: let safe):
            switch type
            {
            case .href, .safelink:
                type = safe ? .safelink : .external
                return url

            case .external:
                return url

            default:
                return nil
            }
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
        case .fallback(let text):
            html[.code] = text

        case .fragment(let text):
            html[.a] { $0.href = "\(URI.Fragment.init(decoded: text))" } = text

        case .bare(line: let line, let id):
            //  Only file links are supported here.
            html ?= self.context.link(source: id, line: line)

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
                    html[.code] = display
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

                switch (target.url, fragment)
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
                    //  This is a link to the current page. We should emit `#` for `href`, so
                    //  that we don’t display a broken link icon.
                    html[.a] { $0.href = "#" } = link.vertex.headline.safe
                }

            case .module?:
                guard
                let link:Unidoc.LinkReference<Unidoc.CultureVertex> = self.context[culture: id]
                else
                {
                    html[.code] = display
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
                    html[.code] = display
                    return
                }

                //  TODO: support URL fragment?
                html[.code] = components
            }

        case .url(let url, safe: let safe):
            html[.a]
            {
                $0.target = "_blank"
                $0.href = url

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
        }
    }
}
