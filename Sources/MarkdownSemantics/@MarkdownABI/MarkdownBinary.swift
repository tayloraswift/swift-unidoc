import MarkdownABI

extension MarkdownBinary
{
    public
    init(from documentation:MarkdownDocumentation)
    {
        self.init(with: documentation.emit(into:))
    }
}
