import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside
{
    public final
    class Complexity:Markdown.BlockAside
    {
        public class override
        var context:Markdown.Bytecode.Context { .complexity }
    }
}
