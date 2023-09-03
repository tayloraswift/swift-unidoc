import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Requires:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .requires }
    }
}
