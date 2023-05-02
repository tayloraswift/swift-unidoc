import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Since:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .since }
    }
}
