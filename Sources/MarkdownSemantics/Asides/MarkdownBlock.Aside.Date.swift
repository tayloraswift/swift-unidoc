import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Date:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .date }
    }
}
