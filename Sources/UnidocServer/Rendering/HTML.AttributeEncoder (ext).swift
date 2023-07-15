import HTML
import MarkdownRendering

extension HTML.AttributeEncoder
{
    @inlinable public
    var highlight:MarkdownSyntaxHighlight?
    {
        get
        {
            nil
        }
        set(value)
        {
            self[.class] = value?.description
        }
    }
}
