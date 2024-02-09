import MarkdownABI

extension MarkdownTable
{
    public final
    class HeaderCell:AnyCell
    {
        class override
        var context:Markdown.Bytecode.Context { .th }
    }
}
