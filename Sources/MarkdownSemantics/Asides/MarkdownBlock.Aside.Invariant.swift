import MarkdownABI
import MarkdownTrees

extension MarkdownBlock.Aside
{
    public final
    class Invariant:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .invariant }
    }
}
