import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside
{
    public final
    class SeeAlso:Markdown.BlockAside
    {
        public class override
        var context:Markdown.Bytecode.Context { .seealso }
    }
}
