import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside {
    public final class Since: Markdown.BlockAside {
        public class override var context: Markdown.Bytecode.Context { .since }
    }
}
