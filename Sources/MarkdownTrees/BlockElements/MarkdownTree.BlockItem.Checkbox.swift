import MarkdownABI

extension MarkdownTree.BlockItem
{
    @frozen public
    enum Checkbox
    {
        case checked
        case unchecked
    }
}
extension MarkdownTree.BlockItem.Checkbox:MarkdownBinaryConvertibleElement
{
    public
    func serialize(into binary:inout MarkdownBinary)
    {
        binary[.input]
        {
            $0[.checked] = self == .checked
            $0[.disabled] = true 
        }
    }
}
