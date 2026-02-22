import MarkdownABI
import MarkdownAST

extension Markdown.BlockAside {
    public final class ToDo: Markdown.BlockAside {
        public class override var context: Markdown.Bytecode.Context { .todo }
    }
}
