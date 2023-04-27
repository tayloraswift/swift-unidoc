import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Important:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .important }
    }
}
