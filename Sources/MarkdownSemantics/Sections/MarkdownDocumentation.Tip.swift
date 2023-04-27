import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Tip:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .tip }
    }
}
