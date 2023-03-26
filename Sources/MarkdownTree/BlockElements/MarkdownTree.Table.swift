extension MarkdownTree
{
    public final
    class Table:Block
    {
        public
        var columns:[Alignment?]
        public
        var head:[TableCell]
        public
        var body:[[TableCell]]

        @inlinable public
        init(columns:[Alignment?] = [], head:[TableCell], body:[[TableCell]])
        {
            self.columns = columns
            self.head = head
            self.body = body
        }
    }
}
