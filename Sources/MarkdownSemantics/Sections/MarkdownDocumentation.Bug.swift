import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Bug:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .bug }
    }
}
