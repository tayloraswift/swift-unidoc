import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Remark:MarkdownBlock.Aside
    {
        public class override
        var context:Markdown.Bytecode.Context { .remark }
    }
}
