import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Bug:MarkdownBlock.Aside
    {
        public class override
        var context:Markdown.Bytecode.Context { .bug }
    }
}
