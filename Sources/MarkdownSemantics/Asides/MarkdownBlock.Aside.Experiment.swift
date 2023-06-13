import MarkdownABI
import MarkdownTrees

extension MarkdownBlock.Aside
{
    public final
    class Experiment:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .experiment }
    }
}
