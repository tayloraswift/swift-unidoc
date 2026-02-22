import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside {
    public final class Throws: Markdown.BlockAside {
        public class override var context: Markdown.Bytecode.Context { .throws }
    }
}
