import MarkdownABI

extension MarkdownTree.Table
{
    @frozen public
    struct Row<Cell> where Cell:AnyCell
    {
        public
        var alignments:[Alignment?]
        public
        var cells:[Cell]

        @inlinable public
        init(alignments:[Alignment?], cells:[Cell])
        {
            self.alignments = alignments
            self.cells = cells
        }
    }
}
extension MarkdownTree.Table.Row:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int
    {
        self.cells.startIndex
    }
    @inlinable public
    var endIndex:Int
    {
        self.cells.endIndex
    }
    @inlinable public
    subscript(index:Int) -> Element
    {
        .init(
            alignment: self.alignments.indices.contains(index) ? self.alignments[index] : nil,
            cell: self.cells[index])
    }
}
extension MarkdownTree.Table.Row:MarkdownBinaryConvertibleElement
{
    public
    func emit(into binary:inout MarkdownBinary)
    {
        binary[.tr]
        {
            for element:Element in self
            {
                element.emit(into: &$0)
            }
        }
    }
}
