import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside
{
    public final
    class Date:Markdown.BlockAside
    {
        public class override
        var context:Markdown.Bytecode.Context { .date }
    }
}
