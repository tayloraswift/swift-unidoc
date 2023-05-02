import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Postcondition:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .postcondition }
    }
}
