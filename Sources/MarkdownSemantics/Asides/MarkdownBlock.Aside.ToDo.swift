import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class ToDo:MarkdownBlock.Aside
    {
        public class override
        var context:Markdown.Bytecode.Context { .todo }
    }
}
