import MarkdownABI
import MarkdownTrees

extension MarkdownBlock.Aside
{
    public final
    class Remark:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .remark }
    }
}
