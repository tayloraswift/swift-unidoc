import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Version:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .version }
    }
}
