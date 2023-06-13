import MarkdownABI
import MarkdownTrees

extension MarkdownBlock.Aside
{
    public final
    class Postcondition:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .postcondition }
    }
}
