import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Precondition:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .precondition }
    }
}
