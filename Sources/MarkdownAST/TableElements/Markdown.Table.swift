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
        /// Recursively calls ``Block/outline(by:)`` for each cell in this table.
        public override
        func outline(by register:(Markdown.InlineAutolink) throws -> Int?) rethrows
        {
            try super.outline(by: register)
            try self.head.outline(by: register)
            for row:Row<BodyCell> in self
            {
                try row.outline(by: register)
            }
        }
        /// Visits this table, and then each of its cells.
        public override
        func traverse(_ visit:(Markdown.BlockElement) throws -> ()) rethrows
        {
            try super.traverse(visit)
            for cell:HeaderCell in self.head.cells
            {
                try cell.traverse(visit)
            }
            for cell:BodyCell in self.body.joined()
            {
                try cell.traverse(visit)
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
