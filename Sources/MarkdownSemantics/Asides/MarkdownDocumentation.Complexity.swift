import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Complexity:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .complexity }
    }
}
