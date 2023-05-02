import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Mutating:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .mutating }
    }
}
