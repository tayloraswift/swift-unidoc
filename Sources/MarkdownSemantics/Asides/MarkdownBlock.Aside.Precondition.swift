import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Precondition:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .precondition }
    }
}
