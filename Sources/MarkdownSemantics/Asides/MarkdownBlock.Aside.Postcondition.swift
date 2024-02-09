import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Postcondition:MarkdownBlock.Aside
    {
        public class override
        var context:Markdown.Bytecode.Context { .postcondition }
    }
}
