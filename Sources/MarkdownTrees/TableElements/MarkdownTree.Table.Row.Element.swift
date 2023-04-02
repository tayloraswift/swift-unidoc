import MarkdownABI

extension MarkdownTree.Table.Row
{
    @frozen public
    struct Element
    {
        public
        let alignment:MarkdownTree.Table.Alignment?
        public
        let cell:Cell

        @inlinable public
        init(alignment:MarkdownTree.Table.Alignment?, cell:Cell)
        {
            self.alignment = alignment
            self.cell = cell
        }
    }
}
extension MarkdownTree.Table.Row.Element:MarkdownBinaryConvertibleElement
{
    public
    func emit(into binary:inout MarkdownBinary)
    {
        self.cell.emit(into: &binary, alignment: self.alignment)
    }
}
