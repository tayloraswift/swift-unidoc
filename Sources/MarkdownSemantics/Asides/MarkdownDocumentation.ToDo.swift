import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class ToDo:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .todo }
    }
}
