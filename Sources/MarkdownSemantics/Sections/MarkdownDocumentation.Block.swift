import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    @frozen public
    enum Block
    {
        case semantic(MarkdownKeywordPrefix, [MarkdownTree.Block])
        case regular(MarkdownTree.Block)
    }
}
extension MarkdownDocumentation.Block
{
    public
    func emit(into binary:inout MarkdownBinary)
    {
        switch self
        {
        case .regular(let block):
            block.emit(into: &binary)
        
        case .semantic(let keywords, let elements):
            binary[keywords.context]
            {
                for block:MarkdownTree.Block in elements
                {
                    block.emit(into: &$0)
                }
            }
        }
    }
}
