import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside {
    public final class Attention: Markdown.BlockAside {
        public class override var context: Markdown.Bytecode.Context { .attention }
    }
}
