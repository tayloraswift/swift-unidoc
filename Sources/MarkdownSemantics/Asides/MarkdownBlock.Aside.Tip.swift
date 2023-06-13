import MarkdownABI
import MarkdownTrees

extension MarkdownBlock.Aside
{
    public final
    class Tip:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .tip }
    }
}
