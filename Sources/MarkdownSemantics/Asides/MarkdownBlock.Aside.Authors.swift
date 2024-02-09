import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Authors:MarkdownBlock.Aside
    {
        public class override
        var context:Markdown.Bytecode.Context { .authors }
    }
}
