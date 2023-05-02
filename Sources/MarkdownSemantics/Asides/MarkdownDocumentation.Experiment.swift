import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Experiment:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .experiment }
    }
}
