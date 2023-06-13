import MarkdownABI
import MarkdownTrees

extension MarkdownBlock.Aside
{
    public final
    class Copyright:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .copyright }
    }
}
