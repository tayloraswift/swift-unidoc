import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Warning:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .warning }
    }
}
