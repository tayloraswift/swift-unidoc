import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Remark:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .remark }
    }
}
