import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Copyright:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .copyright }
    }
}
