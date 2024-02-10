import MarkdownABI

extension Markdown.Table
{
    public
    class AnyCell:Markdown.BlockContainer<Markdown.InlineElement>
    {
        class
        var context:Markdown.Bytecode.Context { .td }

        /// Emits this cell as an element determined by the dynamic type of this instance,
        /// without any alignment attributes.
        public final override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            self.emit(into: &binary, alignment: nil)
        }
    }
}
extension Markdown.Table.AnyCell
{
    final
    func emit(into binary:inout Markdown.BinaryEncoder, alignment:Markdown.Table.Alignment?)
    {
        binary[Self.context]
        {
            switch alignment
            {
            case nil:       return
            case .center?:  $0[.center] = true
            case .left?:    $0[.left] = true
            case .right?:   $0[.right] = true
            }
        }
            content:
        {
            super.emit(into: &$0)
        }
    }
}
