import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Authors:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .authors }
    }
}
