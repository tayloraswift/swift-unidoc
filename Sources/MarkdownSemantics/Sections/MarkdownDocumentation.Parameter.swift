import Codelinks
import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    @frozen public
    struct Parameter
    {
        public
        var elements:[MarkdownTree.Block]
        public
        let name:String

        @inlinable public
        init(elements:[MarkdownTree.Block], name:String)
        {
            self.elements = elements
            self.name = name
        }
    }
}
extension MarkdownDocumentation.Parameter
{
    public
    func emit(into binary:inout MarkdownBinary)
    {
        binary[.dt] = self.name
        binary[.dd]
        {
            for block:MarkdownTree.Block in self.elements
            {
                block.emit(into: &$0)
            }
        }
    }
}
