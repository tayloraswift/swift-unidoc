import MarkdownABI
import Sources

extension Markdown.Table
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
extension Markdown.Table.Row:RandomAccessCollection
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
extension Markdown.Table.Row:Markdown.TreeElement
{
    @inlinable public
    func outline(by register:(Markdown.InlineAutolink) throws -> Int?) rethrows
    {
        for element:Element in self
        {
            try element.outline(by: register)
        }
    }
    public
    func emit(into binary:inout Markdown.BinaryEncoder)
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