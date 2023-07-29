import MarkdownABI

extension MarkdownBytecode
{
    @inlinable public
    var safe:SafeView { .init(self) }
}
