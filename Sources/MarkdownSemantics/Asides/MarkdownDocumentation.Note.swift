import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Note:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .note }
    }
}
