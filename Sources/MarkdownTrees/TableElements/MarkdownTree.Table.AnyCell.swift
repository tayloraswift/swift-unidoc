import MarkdownABI

extension MarkdownTree.Table
{
    public
    class AnyCell:MarkdownTree.BlockContainer<MarkdownTree.InlineBlock>
    {
        class
        var context:MarkdownBytecode.Context { .td }

        /// Emits this cell as an element determined by the dynamic type of this instance,
        /// without any alignment attributes.
        public final override
        func emit(into binary:inout MarkdownBinaryEncoder)
        {
            self.emit(into: &binary, alignment: nil)
        }
    }
}
extension MarkdownTree.Table.AnyCell
{
    final
    func emit(into binary:inout MarkdownBinaryEncoder, alignment:MarkdownTree.Table.Alignment?)
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
