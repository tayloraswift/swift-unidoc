import MarkdownABI

extension MarkdownTable
{
    public final
    class HeaderCell:AnyCell
    {
        class override
        var context:MarkdownBytecode.Context { .th }
    }
}
