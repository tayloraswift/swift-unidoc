import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Precondition:MarkdownBlock.Aside
    {
        public class override
        var context:Markdown.Bytecode.Context { .precondition }
    }
}
