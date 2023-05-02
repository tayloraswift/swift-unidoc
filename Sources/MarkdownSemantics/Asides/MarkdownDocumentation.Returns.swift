import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Returns:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .returns }
    }
}
