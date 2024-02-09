import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside
{
    public final
    class Warning:Markdown.BlockAside
    {
        public class override
        var context:Markdown.Bytecode.Context { .warning }
    }
}
