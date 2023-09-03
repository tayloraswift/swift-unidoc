import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Bug:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .bug }
    }
}
