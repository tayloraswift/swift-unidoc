import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Nonmutating:MarkdownBlock.Aside
    {
        public class override
        var context:Markdown.Bytecode.Context { .nonmutating }
    }
}
