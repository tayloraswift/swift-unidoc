import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Throws:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .throws }
    }
}
