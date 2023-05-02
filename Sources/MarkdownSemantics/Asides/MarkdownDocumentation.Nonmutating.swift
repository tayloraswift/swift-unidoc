import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Nonmutating:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .nonmutating }
    }
}
