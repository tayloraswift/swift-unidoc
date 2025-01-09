import MarkdownAST
import Sources

extension Markdown
{
    /// An `@Article` block behaves identically to an ordinary `@Tutorial` block. It is a
    /// named subclass to allow consumers to detect the tutorial type via dynamic casting.
    public final
    class TutorialArticle:BlockArticle
    {
    }
}
extension Markdown.TutorialArticle:Markdown.BlockDirectiveType
{
    public
    typealias Option = Markdown.Tutorial.Option

    public
    func configure(option:Option, value:Markdown.SourceString)
    {
    }
}
