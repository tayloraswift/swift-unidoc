import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside {
    public final class Tip: Markdown.BlockAside {
        public class override var context: Markdown.Bytecode.Context { .tip }
    }
}
