import MarkdownABI
import Sources

extension Markdown
{
    public
    protocol TreeElement
    {
        func emit(into binary:inout Markdown.BinaryEncoder)
    }
}
