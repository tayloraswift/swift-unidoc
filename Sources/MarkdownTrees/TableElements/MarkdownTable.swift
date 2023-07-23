import MarkdownABI
import Sources

public final
class MarkdownTable:MarkdownBlock
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
    /// Recursively calls ``Block outline(by:)`` for each cell in this table.
    public override
    func outline(by register:(MarkdownInline.Autolink) throws -> Int?) rethrows
    {
        try self.head.outline(by: register)
        for row:Row<BodyCell> in self
        {
            try row.outline(by: register)
        }
    }
    /// Emits a `table` element.
    public override
    func emit(into binary:inout MarkdownBinaryEncoder)
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
extension MarkdownTable
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
extension MarkdownTable:RandomAccessCollection
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
