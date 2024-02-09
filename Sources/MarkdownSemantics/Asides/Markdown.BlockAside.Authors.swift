import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside
{
    public final
    class Authors:Markdown.BlockAside
    {
        public class override
        var context:Markdown.Bytecode.Context { .authors }
    }
}
