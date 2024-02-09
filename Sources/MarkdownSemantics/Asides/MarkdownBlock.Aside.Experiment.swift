import MarkdownABI
import MarkdownAST

extension MarkdownBlock.Aside
{
    public final
    class Experiment:MarkdownBlock.Aside
    {
        public class override
        var context:Markdown.Bytecode.Context { .experiment }
    }
}
