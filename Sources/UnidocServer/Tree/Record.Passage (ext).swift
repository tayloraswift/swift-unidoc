import HTML
import HTMLRendering
import MarkdownRendering
import UnidocRecords

extension Record.Passage
{
    func render(to html:inout HTML.ContentEncoder, with context:RenderingContext)
    {
        let renderer:PassageRenderer = .init(passage: self, context: context)
        let _:MarkdownRenderingError? = renderer.render(to: &html)
    }
}
