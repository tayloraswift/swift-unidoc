import MarkdownABI
import MarkdownTrees

extension MarkdownBlock.Aside
{
    public final
    class Mutating:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .mutating }
    }
}
