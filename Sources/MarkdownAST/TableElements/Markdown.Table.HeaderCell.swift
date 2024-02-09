import MarkdownABI

extension Markdown.Table
{
    public final
    class HeaderCell:AnyCell
    {
        class override
        var context:Markdown.Bytecode.Context { .th }
    }
}
