import MarkdownABI
import MarkdownTrees

extension MarkdownBlock.Aside
{
    public final
    class ToDo:MarkdownBlock.Aside
    {
        public class override
        var context:MarkdownBytecode.Context { .todo }
    }
}
