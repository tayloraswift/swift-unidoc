import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Author:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .author }
    }
}
