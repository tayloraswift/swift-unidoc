import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside {
    public final class Experiment: Markdown.BlockAside {
        public class override var context: Markdown.Bytecode.Context { .experiment }
    }
}
