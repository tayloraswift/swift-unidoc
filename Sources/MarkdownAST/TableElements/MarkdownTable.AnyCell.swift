import MarkdownABI

extension MarkdownTable
{
    public
    class AnyCell:MarkdownBlock.Container<MarkdownInline.Block>
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
extension MarkdownTable.AnyCell
{
    final
    func emit(into binary:inout MarkdownBinaryEncoder, alignment:MarkdownTable.Alignment?)
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
