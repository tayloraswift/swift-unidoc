import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Since:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .since }
    }
}
