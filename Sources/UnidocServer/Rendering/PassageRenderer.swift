import MarkdownABI
import MarkdownRendering
import HTML
import HTMLRendering
import Unidoc
import UnidocRecords

struct PassageRenderer
{
    let passage:Record.Passage
    let context:RenderingContext

    init(passage:Record.Passage, context:RenderingContext)
    {
        self.passage = passage
        self.context = context
    }
}
extension PassageRenderer:MarkdownRenderer
{
    var bytecode:MarkdownBytecode { self.passage.markdown }

    func load(_ reference:UInt32, into html:inout HTML)
    {
        guard   let index:Int = .init(exactly: reference),
                self.passage.referents.indices.contains(index)
        else
        {
            return
        }

        switch self.passage.referents[index]
        {
        case .text(let text):
            html[.code] = text

        case .path(let path):
            html[.code]
            {
                var first:Bool = true
                for _:Unidoc.Scalar in path
                {
                    if  first
                    {
                        first = false
                    }
                    else
                    {
                        $0[.span] = "."
                    }

                    $0[.a, { $0[.href] = "" }] = "_"
                }
            }
        }
    }
}
