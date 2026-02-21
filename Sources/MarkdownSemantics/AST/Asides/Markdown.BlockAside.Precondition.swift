import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside {
    public final class Precondition: Markdown.BlockAside {
        public class override var context: Markdown.Bytecode.Context { .precondition }
    }
}
