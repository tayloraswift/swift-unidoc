import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside
{
    public final
    class Copyright:Markdown.BlockAside
    {
        public class override
        var context:Markdown.Bytecode.Context { .copyright }
    }
}
