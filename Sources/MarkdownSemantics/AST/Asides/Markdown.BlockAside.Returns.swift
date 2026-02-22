import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside {
    public final class Returns: Markdown.BlockAside {
        public class override var context: Markdown.Bytecode.Context { .returns }
    }
}
