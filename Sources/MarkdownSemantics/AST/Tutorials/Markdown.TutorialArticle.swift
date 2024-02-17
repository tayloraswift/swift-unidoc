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
    func configure(option:String, value:String, from _:SourceReference<Markdown.Source>) throws
    {
        switch option
        {
        case "time":
            break

        case let option:
            throw ArgumentError.unexpected(option)
        }
    }
}
