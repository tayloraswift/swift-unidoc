import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside
{
    public final
    class Invariant:Markdown.BlockAside
    {
        public class override
        var context:Markdown.Bytecode.Context { .invariant }
    }
}
