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
    /// Emits an `input` element.
    public
    func emit(into binary:inout MarkdownBinary)
    {
        binary[.input]
        {
            $0[.checked] = self == .checked
            $0[.checkbox] = true
            $0[.disabled] = true
        }
    }
}
