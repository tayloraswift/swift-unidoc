import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside {
    public final class Bug: Markdown.BlockAside {
        public class override var context: Markdown.Bytecode.Context { .bug }
    }
}
