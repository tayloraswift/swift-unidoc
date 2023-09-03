import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Version:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .version }
    }
}
