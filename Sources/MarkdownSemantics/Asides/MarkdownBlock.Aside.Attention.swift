import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Attention:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .attention }
    }
}
