import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Date:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .date }
    }
}
