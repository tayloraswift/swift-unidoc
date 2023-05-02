import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class SeeAlso:MarkdownTree.BlockAside
    {
        public class override
        var context:MarkdownBytecode.Context { .seealso }
    }
}
