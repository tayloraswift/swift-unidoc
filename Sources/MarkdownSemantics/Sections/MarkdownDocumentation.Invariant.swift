import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Invariant:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .invariant }
    }
}
