import MarkdownABI

extension MarkdownTree.Table
{
    public final
    class HeaderCell:AnyCell
    {
        class override
        var context:MarkdownBytecode.Context { .th }
    }
}
