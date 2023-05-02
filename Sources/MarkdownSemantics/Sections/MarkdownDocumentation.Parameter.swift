import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Parameter:MarkdownTree.BlockContainer<MarkdownTree.Block>
    {
        public
        let name:String

        @inlinable public
        init(elements:[MarkdownTree.Block], name:String)
        {
            self.name = name
            super.init(elements)
        }
        public override
        func emit(into binary:inout MarkdownBinaryEncoder)
        {
            binary[.dt] = self.name
            binary[.dd]
            {
                super.emit(into: &$0)
            }
        }
    }
}
extension MarkdownDocumentation.Parameter
{
}
