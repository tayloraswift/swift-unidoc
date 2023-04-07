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
extension MarkdownTree.Table.Row.Element:MarkdownElement
{
    @inlinable public
    func outline(by register:(_ symbol:String) throws -> UInt32) rethrows
    {
        try self.cell.outline(by: register)
    }

    public
    func emit(into binary:inout MarkdownBinary)
    {
        self.cell.emit(into: &binary, alignment: self.alignment)
    }
}
