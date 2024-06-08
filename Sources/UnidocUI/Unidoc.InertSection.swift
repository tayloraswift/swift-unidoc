import HTML
import MarkdownABI
import MarkdownRendering
import SymbolGraphs

extension Unidoc
{
    /// An `InertSection` displays linkable references as inert text. It is useful in situations
    /// where emitting clickable anchors would not be desirable.
    ///
    /// Because this type never computes any URLs, it does not require access to a full
    /// ``VertexContext``, only a ``VertexContextTable``.
    ///
    /// >   Warning:
    ///     `InertView` does not guarantee that the rendered HTML contains no links, only that
    ///     no additional links are injected into the HTML.
    struct InertSection<Table> where Table:VertexContextTable
    {
        let bytecode:Markdown.Bytecode
        let outlines:[Outline]
        let vertices:Table

        init(
            bytecode:Markdown.Bytecode,
            outlines:[Outline],
            vertices:Table)
        {
            self.bytecode = bytecode
            self.outlines = outlines
            self.vertices = vertices
        }
    }
}
extension Unidoc.InertSection
{
    init(overview:Unidoc.Passage, vertices:Table)
    {
        self.init(
            bytecode: overview.markdown,
            outlines: overview.outlines,
            vertices: vertices)
    }
}
extension Unidoc.InertSection:HTML.OutputStreamableMarkdown
{
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
        case .external(https: let url, safe: _):
            html += url

        case .fragment(let text):
            html[.span] = text

        case .fallback(text: let text):
            html[.code] = text

        case .bare(line: let line, let id):
            guard
            let file:Unidoc.FileVertex = self.vertices[id]?.vertex.file
            else
            {
                return
            }

            html[.code] = line.map { "\(file.symbol.last):\($0 + 1)" } ?? file.symbol.last

        case .path(let display, let vector):
            if  let id:Unidoc.Scalar = vector.last,
                case .article(let vertex)? = self.vertices[id]?.vertex
            {
                html[.span] = vertex.headline.safe
            }
            else
            {
                html[.code] = display
            }
        }
    }
}
extension Unidoc.InertSection:TextOutputStreamableMarkdown
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
        case .external(https: let url, safe: _):
            utf8 += url.utf8

        case .fragment(let fragment):
            utf8 += fragment.utf8

        case .fallback(let text?):
            utf8 += text.utf8

        case .fallback(nil):
            break

        case .bare(line: let line, let id):
            guard
            let file:Unidoc.FileVertex = self.vertices[id]?.vertex.file
            else
            {
                break
            }

            utf8 += file.symbol.last.utf8

            guard
            let line:Int = line
            else
            {
                break
            }

            utf8 += ":\(line + 1)".utf8

        case .path(let display, let vector):
            if  let id:Unidoc.Scalar = vector.last,
                case .article(let vertex)? = self.vertices[id]?.vertex
            {
                try? vertex.headline.safe.write(to: &utf8)
            }
            else
            {
                for byte:UInt8 in display.path.utf8
                {
                    utf8.append(byte == 0x20 ? 0x2E : byte)
                }
            }
        }
    }
}
