import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Attention:MarkdownBlock.Aside
    {
        public class override
        var context:Markdown.Bytecode.Context { .attention }
    }
}
