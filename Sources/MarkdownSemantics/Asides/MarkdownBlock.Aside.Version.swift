import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Version:MarkdownBlock.Aside
    {
        public class override
        var context:Markdown.Bytecode.Context { .version }
    }
}
