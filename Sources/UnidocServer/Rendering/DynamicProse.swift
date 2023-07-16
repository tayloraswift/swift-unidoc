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
            html[.code] = self.inliner.link(stem.split(separator: " "), to: scalars)
        }
    }
}
