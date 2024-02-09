import MarkdownABI
import Sources

extension Markdown
{
    public final
    class Table:Markdown.BlockElement
    {
        public
        var head:Row<HeaderCell>
        public
        var body:[[BodyCell]]

        public
        init(columns:[Alignment?] = [], head:[HeaderCell], body:[[BodyCell]])
        {
            self.head = .init(alignments: columns, cells: head)
            self.body = body
        }
        /// Recursively calls ``Block/outline(by:)`` for each cell in this table.
        public override
        func outline(by register:(Markdown.InlineAutolink) throws -> Int?) rethrows
        {
            try self.head.outline(by: register)
            for row:Row<BodyCell> in self
            {
                try row.outline(by: register)
            }
        }
        /// Emits a `table` element.
        public override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.table]
            {
                $0[.thead] = self.head
                $0[.tbody]
                {
                    for row:Row<BodyCell> in self
                    {
                        row.emit(into: &$0)
                    }
                }
            }
        }
    }
}
extension Markdown.Table
{
    @inlinable public
    var columns:[Alignment?]
    {
        _read
        {
            yield  self.head.alignments
        }
        _modify
        {
            yield &self.head.alignments
        }
    }
}
extension Markdown.Table:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int
    {
        self.body.startIndex
    }
    @inlinable public
    var endIndex:Int
    {
        self.body.endIndex
    }
    @inlinable public
    subscript(row:Int) -> Row<BodyCell>
    {
        .init(alignments: self.columns, cells: self.body[row])
    }
}
