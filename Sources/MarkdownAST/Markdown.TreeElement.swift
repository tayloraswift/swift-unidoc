import MarkdownABI
import Sources

extension Markdown
{
    public
    typealias TreeElement = _MarkdownTreeElement
}
/// The name of this protocol is ``Markdown.TreeElement``.
public
protocol _MarkdownTreeElement
{
    func emit(into binary:inout Markdown.BinaryEncoder)
}
