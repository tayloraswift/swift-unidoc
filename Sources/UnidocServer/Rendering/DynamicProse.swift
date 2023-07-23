import MarkdownABI
import MarkdownRendering
import HTML
import Unidoc
import UnidocRecords

struct DynamicProse
{
    private
    let passage:Record.Passage
    private
    let inliner:Inliner

    init(passage:Record.Passage, inliner:Inliner)
    {
        self.passage = passage
        self.inliner = inliner
    }
}
extension DynamicProse:HyperTextRenderableMarkdown
{
    var bytecode:MarkdownBytecode { self.passage.markdown }

    func load(_ reference:Int, into html:inout HTML.ContentEncoder)
    {
        guard self.passage.outlines.indices.contains(reference)
        else
        {
            return
        }

        switch self.passage.outlines[reference]
        {
        case .text(let text):
            html[.code] = text

        case .path(let stem, let scalars):
            html[.code] = self.inliner.link(stem.split(separator: " "), to: scalars)
        }
    }
}
