import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Warning:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .warning }
    }
}
