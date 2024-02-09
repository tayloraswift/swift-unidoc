import MarkdownABI

extension Markdown.Bytecode
{
    @inlinable public
    var safe:SafeView { .init(self) }
}
