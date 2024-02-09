import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Complexity:MarkdownBlock.Aside
    {
        public class override
        var context:Markdown.Bytecode.Context { .complexity }
    }
}
