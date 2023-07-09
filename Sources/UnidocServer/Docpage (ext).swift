import HTML
import HTMLRendering
import UnidocDatabase

extension Docpage:RenderableAsHTML
{
    public
    func render(to html:inout HTML)
    {
        let context:RenderingContext = .init()

        html[.html]
        {
            $0[.head]
            {
                $0[.title] = "" // "\(self.principal.first?.master?.title))"
            }
            $0[.body]
            {
                $0[.h1] = "" // "\(self.principal.first?.master?.name))"

                self.principal.master?.details?.render(to: &$0, with: context)
            }
        }
    }
}

import UnidocRecords
import MarkdownRendering

extension Record.Passage
{
    func render(to html:inout HTML, with context:RenderingContext)
    {
        let renderer:PassageRenderer = .init(passage: self, context: context)
        let _:MarkdownRenderingError? = renderer.render(to: &html)
    }
}
