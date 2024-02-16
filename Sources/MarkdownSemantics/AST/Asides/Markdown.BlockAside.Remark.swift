import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside
{
    public final
    class Remark:Markdown.BlockAside
    {
        public class override
        var context:Markdown.Bytecode.Context { .remark }
    }
}
