import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Note:MarkdownBlock.Aside
    {
        public class override
        var context:Markdown.Bytecode.Context { .note }
    }
}
