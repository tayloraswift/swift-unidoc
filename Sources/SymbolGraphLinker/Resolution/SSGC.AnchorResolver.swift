import MarkdownSemantics
import UCF

extension SSGC
{
    public
    struct AnchorResolver
    {
        private
        var table:[Int32: [UCF.AnchorMangling: String]]

        public
        init(table:[Int32: [UCF.AnchorMangling: String]] = [:])
        {
            self.table = table
        }
    }
}
extension SSGC.AnchorResolver
{
    mutating
    func index(sections:Markdown.SemanticSections, of id:Int32)
    {
        let anchors:[UCF.AnchorMangling: String] = sections.anchors()
        if  anchors.isEmpty
        {
            return
        }

        self.table[id] = anchors
    }
}
