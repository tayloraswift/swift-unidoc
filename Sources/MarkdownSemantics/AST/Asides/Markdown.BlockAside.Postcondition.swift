import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside {
    public final class Postcondition: Markdown.BlockAside {
        public class override var context: Markdown.Bytecode.Context { .postcondition }
    }
}
