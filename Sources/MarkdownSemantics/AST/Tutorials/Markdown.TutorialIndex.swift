import MarkdownAST
import Sources

extension Markdown {
    /// A `@Tutorials` block behaves identically to an ordinary `@Tutorial` block. It is a
    /// named subclass to allow consumers to detect the tutorial type via dynamic casting.
    public final class TutorialIndex: BlockArticle {
    }
}
extension Markdown.TutorialIndex: Markdown.BlockDirectiveType {
    @frozen public enum Option: String, Markdown.BlockDirectiveOption {
        case name
    }

    public func configure(option: Option, value: Markdown.SourceString) {
        switch option {
        case .name:
            //  This is almost always the package name, and thus utterly redundant.
            break
        }
    }
}
