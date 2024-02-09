import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Since:MarkdownBlock.Aside
    {
        public class override
        var context:Markdown.Bytecode.Context { .since }
    }
}
