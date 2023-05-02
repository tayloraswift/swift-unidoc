import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Attention:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .attention }
    }
}
