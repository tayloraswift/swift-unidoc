import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Requires:MarkdownBlock.Aside
    {
        public class override
        var context:Markdown.Bytecode.Context { .requires }
    }
}
