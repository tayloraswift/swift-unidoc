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
    func index(article:Markdown.SemanticSections, id:Int32?) -> SSGC.AnchorTable
    {
        let anchors:[UCF.AnchorMangling: String] = article.anchors()

        if  let id:Int32, !anchors.isEmpty
        {
            self.table[id] = anchors
        }

        return .init(scope: id, table: anchors)
    }

    subscript(scope:Int32) -> SSGC.AnchorTable
    {
        .init(scope: scope, table: self.table[scope] ?? [:])
    }
}
