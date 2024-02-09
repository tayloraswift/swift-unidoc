import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Mutating:MarkdownBlock.Aside
    {
        public class override
        var context:Markdown.Bytecode.Context { .mutating }
    }
}
