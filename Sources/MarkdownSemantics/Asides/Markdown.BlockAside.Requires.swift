import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside
{
    public final
    class Requires:Markdown.BlockAside
    {
        public class override
        var context:Markdown.Bytecode.Context { .requires }
    }
}
