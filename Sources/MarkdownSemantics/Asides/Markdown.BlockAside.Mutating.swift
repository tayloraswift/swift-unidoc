import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside
{
    public final
    class Mutating:Markdown.BlockAside
    {
        public class override
        var context:Markdown.Bytecode.Context { .mutating }
    }
}
