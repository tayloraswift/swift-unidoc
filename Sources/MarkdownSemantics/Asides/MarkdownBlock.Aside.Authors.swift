import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Authors:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .authors }
    }
}
