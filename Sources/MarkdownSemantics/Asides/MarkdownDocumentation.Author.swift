import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Author:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .author }
    }
}
