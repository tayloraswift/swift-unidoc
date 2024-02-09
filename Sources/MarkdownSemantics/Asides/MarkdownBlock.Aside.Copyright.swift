import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Copyright:MarkdownBlock.Aside
    {
        public class override
        var context:Markdown.Bytecode.Context { .copyright }
    }
}
