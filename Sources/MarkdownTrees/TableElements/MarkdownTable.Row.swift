import MarkdownABI
import Sources

extension MarkdownTable
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
extension MarkdownTable.Row:RandomAccessCollection
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
extension MarkdownTable.Row:MarkdownElement
{
    @inlinable public
    func outline(by register:(String, SourceText<Int>?) throws -> UInt32?) rethrows
    {
        for element:Element in self
        {
            try element.outline(by: register)
        }
    }
    public
    func emit(into binary:inout MarkdownBinaryEncoder)
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
