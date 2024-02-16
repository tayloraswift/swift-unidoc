import MarkdownAST

extension Markdown
{
    /// A `@Tutorials` block behaves identically to an ordinary `@Tutorial` block. It is a
    /// named subclass to allow consumers to detect the tutorial type via dynamic casting.
    public final
    class Tutorials:Tutorial
    {
    }
}
