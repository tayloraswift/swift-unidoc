import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Requires:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .requires }
    }
}
