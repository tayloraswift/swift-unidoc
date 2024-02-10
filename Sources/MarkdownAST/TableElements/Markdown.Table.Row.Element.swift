import MarkdownABI
import Sources

extension Markdown.Table.Row
{
    @frozen public
    struct Element
    {
        public
        let alignment:Markdown.Table.Alignment?
        public
        let cell:Cell

        @inlinable public
        init(alignment:Markdown.Table.Alignment?, cell:Cell)
        {
            self.alignment = alignment
            self.cell = cell
        }
    }
}
extension Markdown.Table.Row.Element:Markdown.TreeElement
{
    @inlinable public
    func outline(by register:(Markdown.InlineAutolink) throws -> Int?) rethrows
    {
        try self.cell.outline(by: register)
    }

    public
    func emit(into binary:inout Markdown.BinaryEncoder)
    {
        self.cell.emit(into: &binary, alignment: self.alignment)
    }
}
