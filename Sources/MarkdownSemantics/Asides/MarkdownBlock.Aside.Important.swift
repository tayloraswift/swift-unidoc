import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Important:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .important }
    }
}
