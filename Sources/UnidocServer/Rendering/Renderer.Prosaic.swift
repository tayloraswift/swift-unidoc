import MarkdownABI
import MarkdownRendering
import HTML
import Unidoc
import UnidocRecords

extension Renderer
{
    struct Prosaic
    {
        private
        let renderer:Renderer
        private
        let passage:Record.Passage

        init(_ renderer:Renderer, passage:Record.Passage)
        {
            self.renderer = renderer
            self.passage = passage
        }
    }
}
extension Renderer.Prosaic:HyperTextRenderableMarkdown
{
    var bytecode:MarkdownBytecode { self.passage.markdown }

    func load(_ reference:UInt32, into html:inout HTML.ContentEncoder)
    {
        guard   let index:Int = .init(exactly: reference),
                self.passage.outlines.indices.contains(index)
        else
        {
            return
        }

        switch self.passage.outlines[index]
        {
        case .text(let text):
            html[.code] = text

        case .path(let stem, let scalars):
            html[.code] = self.renderer.link(stem.split(separator: " "), to: scalars)
        }
    }
}
