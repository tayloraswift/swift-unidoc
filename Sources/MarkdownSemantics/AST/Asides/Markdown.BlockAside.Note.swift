import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside
{
    public final
    class Note:Markdown.BlockAside
    {
        public class override
        var context:Markdown.Bytecode.Context { .note }
    }
}
