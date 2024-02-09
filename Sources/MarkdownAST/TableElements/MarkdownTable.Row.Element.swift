import MarkdownABI
import Sources

extension MarkdownTable.Row
{
    @frozen public
    struct Element
    {
        public
        let alignment:MarkdownTable.Alignment?
        public
        let cell:Cell

        @inlinable public
        init(alignment:MarkdownTable.Alignment?, cell:Cell)
        {
            self.alignment = alignment
            self.cell = cell
        }
    }
}
extension MarkdownTable.Row.Element:MarkdownElement
{
    @inlinable public
    func outline(by register:(MarkdownInline.Autolink) throws -> Int?) rethrows
    {
        try self.cell.outline(by: register)
    }

    public
    func emit(into binary:inout Markdown.BinaryEncoder)
    {
        self.cell.emit(into: &binary, alignment: self.alignment)
    }
}
